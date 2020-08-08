# http://k.ylo.ph/2016/04/04/loudnorm.html
import json, cligen, os, strformat, osproc, strutils

let outputFormat = "linear=true:print_format=summary"

proc extractDetails(termLines:seq[string]): JsonNode =
    return termLines[len(termLines)-13..len(termLines)-2].join("").parseJson()

proc entry*(input: seq[string], targetLUFS:float= -14.0, targetRange:float = 7.0, truePeak:float = -1.0, sampleRate:int = 44100): void =
    if input.len() == 0:
        echo "Please provide one or more files to process."
    for p in input: # iterate overa ll files
        var inFile = p.absolutePath()
        var outFile = joinPath(p.splitFile().dir, fmt"{p.splitFile().name}_corrected.wav").absolutePath()
        
        var firstPassCmd = fmt("ffmpeg -i {inFile} -filter:a loudnorm=I={targetLUFS}:LRA={targetRange}:truePeak={truePeak}:print_format=json -f null -")
        var firstPass = osproc.execProcess(firstPassCmd).splitLines()
        var d = firstPass.extractDetails()
        echo d
        var measuredI = d["input_i"].getStr()
        var measuredLRA = d["input_lra"].getStr()
        var measuredTP = d["input_tp"].getStr()
        var measuredThresh = d["input_thresh"].getStr()
        var offset = d["target_offset"].getStr()
        var filter = fmt("loudnorm=I={targetLUFS}:LRA={targetRange}:truePeak={truePeak}:measured_I={measuredI}:measured_LRA={measuredLRA}:measured_tp={measuredTP}:measured_thresh={measuredThresh}:offset={offset}:{outputFormat}")
        var secondPassCmd = fmt("ffmpeg -i {inFile} -filter:a {filter} -ar {sampleRate} -c:a pcm_s32le {outFile}")
        discard os.execShellCmd(secondPassCmd)

when isMainModule:
    dispatch(entry,
        short = {
            "targetLUFS" : 't',
            "targetRange" : 'r',
            "truePeak" : 'p',
            "sampleRate" : 's'
        },
        help = {
            "input" : "Multiple files or a single file to process",
            "targetLUFS" : "Target LUFS",
            "targetRange" : "Target range",
            "truePeak" : "Maximum true peak",
            "sampleRate" : "Output sampling rate"
        })
