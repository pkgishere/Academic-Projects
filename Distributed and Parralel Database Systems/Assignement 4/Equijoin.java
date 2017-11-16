import java.io.IOException;
import java.util.ArrayList;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.KeyValueTextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;

public class Equijoin {

	static String table1 = "";
	static String table2 = "";

	public static class Mapping extends Mapper<Text, Text, Text, Text> 
	{
		Text column = new Text();

		public void map(Text key, Text value, Context context) throws IOException, InterruptedException {
			if(key.toString().split(",").length >1)
			{
				column.set(key.toString().split(",")[1]);
				System.out.println("Column:"+column.toString()+"\t Value:"+key.toString());
				context.write(column, key);
			}
			else{
				System.out.println("KEY:"+key);
				System.out.println("Value:"+value);
				System.out.println("I am small");
			}
		}
	}

	public static class Reducing extends Reducer<Text, Text, Text, Text> 
	{
		Text output = new Text();
		ArrayList<String> table_1;
		ArrayList<String> table_2;
		public void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
			table_1 = new ArrayList<String>();
			table_2 = new ArrayList<String>();
			for (Text line : values) 
			{
				System.out.println("Inside REducer:"+line.toString()+"\t KEY:"+key.toString());
				String table = line.toString().split(",")[0];
				if(table_1.size()==0)
				{
					table_1.add(line.toString());
				}
				else
				{
					if(table_1.get(0).split(",")[0].equals(table))
					{
						table_1.add(line.toString());
					}
					else
					{
						table_2.add(line.toString());
					}

				}
			}
			if(table_1.size() > 0 && table_2.size() >0)
			{
				for(int i=0;i<table_1.size();i++)
				{
					for (int j=0;j<table_2.size();j++)
					{
						output.set(table_1.get(i)+","+table_2.get(j));
						context.write(null, output);
						output.clear();
					}
				}
			}
		}
	}





	public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException 
	{

		Configuration conf = new Configuration();
		Job job = Job.getInstance(conf, "equiJoin");
		job.setJarByClass(Equijoin.class);
		job.setMapperClass(Mapping.class);
		job.setReducerClass(Reducing.class);
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(Text.class);
		job.setMapOutputKeyClass(Text.class);
		job.setMapOutputValueClass(Text.class);
		job.setInputFormatClass(KeyValueTextInputFormat.class);
		job.setOutputFormatClass(TextOutputFormat.class);
		FileInputFormat.addInputPath(job, new Path(args[args.length-2]));
		FileOutputFormat.setOutputPath(job, new Path(args[args.length-1]));
		job.waitForCompletion(true);
	}
}
