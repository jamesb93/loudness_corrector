# http://k.ylo.ph/2016/04/04/loudnorm.html
import argparse
import json
from subprocess import run, PIPE
from pathlib import Path

parser = argparse.ArgumentParser(description="Adjust the loudness of audio files.")
parser.add_argument("i", type=str, nargs="+", help="Input file or files")
parser.add_argument("-t", type=float, default=-14.0, help="Integrated loudness target")
parser.add_argument("-r", type=float, default=7, help="Loudness range")
parser.add_argument("-tp", type=float, default=-1.0, help="Max true peak")
parser.add_argument("-sr", type=int, default=44100, help="Output sample rate")

args = parser.parse_args()


def process(input_file, integrated, lra, true_peak_max, sample_rate):
    out_opts = {"ar": sample_rate, "c:a": "pcm_s32le"}

    p = Path(input_file)
    infile = p.resolve()
    outfile = p.parent / f"{p.stem}_corrected.wav"

    # First pass to get statistics
    first_pass_cmd = [
        "ffmpeg","-i",
        str(infile),
        "-filter:a",
        f"loudnorm=I={args.t}:LRA={args.r}:TP={args.tp}:print_format=json",
        "-f",
        "null",
        "-",
    ]
    first_pass = run(first_pass_cmd, stdout=PIPE, stderr=PIPE)
    # horribly extract the json output
    params = first_pass.stderr.decode("utf-8").splitlines()[-12:]
    param_str = "".join(params)
    d = json.loads(param_str)

    # construct the filter string
    filt = "loudnorm="
    filt += f"I={args.t}:"
    filt += f"LRA={args.r}:"
    filt += f"TP={args.tp}:"
    filt += f"measured_I={d['input_i']}:"
    filt += f"measured_LRA={d['input_lra']}:"
    filt += f"measured_tp={d['input_tp']}:"
    filt += f"measured_thresh={d['input_thresh']}:"
    filt += f"offset={d['target_offset']}:"
    filt += f"linear=true:print_format=summary"

    second_pass_cmd = [
        "ffmpeg","-i", str(infile),
        "-filter:a", filt,
        "-ar", str(args.sr),
        "-c:a", "pcm_s32le",
        str(outfile),
    ]
    run(second_pass_cmd)


if __name__ == "__main__":
    for x in args.i:
        process(x, args.t, args.r, args.tp, args.sr)

