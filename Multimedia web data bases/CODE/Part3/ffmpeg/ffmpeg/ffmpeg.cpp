// ffmpegTest.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "stdio.h"
#include "conio.h"

extern "C"
{
#include <libavutil/motion_vector.h>
#include <libavformat/avformat.h>
# pragma comment (lib, "avformat.lib")
}
static AVFormatContext *fmt_ctx = NULL;
static AVCodecContext *video_dec_ctx = NULL;
static AVStream *video_stream = NULL;
static const char *src_filename = NULL;

static int video_stream_idx = -1;
static AVFrame *frame = NULL;
static AVPacket pkt;
static int video_frame_count = 0;
static FILE *filepointer;

float row, column, scaleR, scaleC;
int X, Y, R,CellNo;


static int decode_packet(int *got_frame, int cached)
{
	int decoded = pkt.size;

	*got_frame = 0;

	if (pkt.stream_index == video_stream_idx) {
		int ret = avcodec_decode_video2(video_dec_ctx, frame, got_frame, &pkt);
		if (ret < 0) {
			//TODO : Fix the below line
			//fprintf(stderr, "Error decoding video frame (%s)\n", av_err2str(ret));
			return ret;
		}

		if (*got_frame) {
			int i;
			AVFrameSideData *sd;

			video_frame_count++;
			sd = av_frame_get_side_data(frame, AV_FRAME_DATA_MOTION_VECTORS);
			if (sd) {
				const AVMotionVector *mvs = (const AVMotionVector *)sd->data;
				for (i = 0; i < sd->size / sizeof(*mvs); i++) {
					const AVMotionVector *mv = &mvs[i];
					R = 6;

					scaleR = 160.0 / R;
					scaleC = 120.0 / R;
					X = floor((mv->dst_x) / scaleR);
					X = X + 1;
					Y = floor((mv->dst_y) / scaleC);
					Y = Y + 1;
					if (mv->dst_y == 120) {
						Y = Y - 1;
					}
					if (mv->dst_x == 160) {
						X = X - 1;
					}
					CellNo = R * (X - 1) + Y;


					//printf("%d %d %d %d %d %d %d %d 0x%\n",PRIx64,"\n",
					/*fprintf(filepointer,"CELL NO %d VIDEO NO %d SOURCE %d W %d H %d SOURCEX %d SOURCEY %d DESTINATION X %d DESTINATION Y %d\n",
						video_frame_count, mv->source,
						mv->w, mv->h, mv->src_x, mv->src_y,
						mv->dst_x, mv->dst_y);*/
					fprintf(filepointer,"----------------------------------------------------------------------------\n");
					printf("%d %d %d %d %d %d %d %d %d\n",
						video_frame_count, mv->source,
						mv->w, mv->h, mv->src_x, mv->src_y,
						mv->dst_x, mv->dst_y, mv->flags);
					fprintf(filepointer, "\n Cell number %d \n", CellNo);
					fprintf(filepointer, "%d %d %d %d %d %d %d %d %d\n",
						video_frame_count, mv->source,
						mv->w, mv->h, mv->src_x, mv->src_y,
						mv->dst_x, mv->dst_y, mv->flags);
					printf("----------------------------------------------------------------------------\n");

					//printf("I am Here %d\n",i);
				}
			}
		}
	}

	return decoded;
}

static int open_codec_context(int *stream_idx,
	AVFormatContext *fmt_ctx, enum AVMediaType type)
{
	int ret;
	AVStream *st;
	AVCodecContext *dec_ctx = NULL;
	AVCodec *dec = NULL;
	AVDictionary *opts = NULL;

	ret = av_find_best_stream(fmt_ctx, type, -1, -1, NULL, 0);
	if (ret < 0) {
		fprintf(stderr, "Could not find %s stream in input file '%s'\n",
			av_get_media_type_string(type), src_filename);
		return ret;
	}
	else {
		*stream_idx = ret;
		st = fmt_ctx->streams[*stream_idx];

		/* find decoder for the stream */
		dec_ctx = st->codec;
		dec = avcodec_find_decoder(dec_ctx->codec_id);
		if (!dec) {
			fprintf(stderr, "Failed to find %s codec\n",
				av_get_media_type_string(type));
			return AVERROR(EINVAL);
		}

		/* Init the video decoder */
		av_dict_set(&opts, "flags2", "+export_mvs", 0);
		if ((ret = avcodec_open2(dec_ctx, dec, &opts)) < 0) {
			fprintf(stderr, "Failed to open %s codec\n",
				av_get_media_type_string(type));
			return ret;
		}
	}

	return 0;
}

int main(int argc, char **argv)
{
	int ret = 0, got_frame, i;
	filepointer = fopen("Phase1Q3.txt", "wt");


	for (i = 1; i < argc; i++) {
		src_filename = argv[i];
		fprintf(filepointer,"ASSUMPTION OF R = 6");
		fprintf(filepointer, "\nVIDEO %d\n", i);

		av_register_all();

		if (avformat_open_input(&fmt_ctx, src_filename, NULL, NULL) < 0) {
			fprintf(stderr, "Could not open source file %s\n", src_filename);
			exit(1);
		}

		if (avformat_find_stream_info(fmt_ctx, NULL) < 0) {
			fprintf(stderr, "Could not find stream information\n");
			exit(1);
		}

		if (open_codec_context(&video_stream_idx, fmt_ctx, AVMEDIA_TYPE_VIDEO) >= 0) {
			video_stream = fmt_ctx->streams[video_stream_idx];
			video_dec_ctx = video_stream->codec;
		}

		av_dump_format(fmt_ctx, 0, src_filename, 0);

		if (!video_stream) {
			fprintf(stderr, "Could not find video stream in the input, aborting\n");
			ret = 1;
			goto end;
		}

		frame = av_frame_alloc();
		if (!frame) {
			fprintf(stderr, "Could not allocate frame\n");
			ret = AVERROR(ENOMEM);
			goto end;
		}

		printf("framenum,source,blockw,blockh,srcx,srcy,dstx,dsty,flags\n");

		/* initialize packet, set data to NULL, let the demuxer fill it */
		av_init_packet(&pkt);
		pkt.data = NULL;
		pkt.size = 0;

		/* read frames from the file */
		while (av_read_frame(fmt_ctx, &pkt) >= 0) {
			AVPacket orig_pkt = pkt;
			do {
				ret = decode_packet(&got_frame, 0);
				if (ret < 0)
					break;
				pkt.data += ret;
				pkt.size -= ret;
			} while (pkt.size > 0);
			av_packet_unref(&orig_pkt);
		}

		/* flush cached frames */
		pkt.data = NULL;
		pkt.size = 0;
		do {
			decode_packet(&got_frame, 1);
		} while (got_frame);

	end:
		avcodec_close(video_dec_ctx);
		avformat_close_input(&fmt_ctx);
		av_frame_free(&frame);
	}
	fclose(filepointer);
	return ret < 0;
}


