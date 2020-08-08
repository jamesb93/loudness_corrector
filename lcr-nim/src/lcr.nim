# http://k.ylo.ph/2016/04/04/loudnorm.html
import json, cligen, os, strformat, osproc, strutils, colorize

let outputFormat = "linear=true:print_format=summary"

proc extractDetails(termLines:seq[string]): JsonNode =
    return termLines[len(termLines)-13..len(termLines)-2].join("").parseJson()

proc entry*(input: seq[string], 
    targetLUFS:float= -14.0, 
    targetRange:float = 7.0, 
    truePeak:float = -1.0, 
    sampleRate:int = 44100,
    verbose:bool = true): void =
    if input.len() == 0:
        echo "Please provide one or more files to process.".bold.fgRed
    for p in input: # iterate overa ll files

        if verbose: echo fmt"{p.splitFile().name}".fgYellow
        var inFile = fmt("'{p}'")
        var outFile = joinPath(p.splitFile().dir, fmt"'{p.splitFile().name}_corrected.wav'")
        
        var firstPassCmd = fmt("ffmpeg -i {inFile} -filter:a loudnorm=I={targetLUFS}:LRA={targetRange}:TP={truePeak}:print_format=json -f null -")
        var firstPass = osproc.execProcess(firstPassCmd).splitLines()
        echo firstPass
        var d: JsonNode
        try:
            d = firstPass.extractDetails()
            echo d
        except JsonParsingError:
            echo "There was a problem parsing the first pass parameters.".bold.fgRed
            quit()
        
        var measuredI = d["input_i"].getStr()
        var measuredLRA = d["input_lra"].getStr()
        var measuredTP = d["input_tp"].getStr()
        var measuredThresh = d["input_thresh"].getStr()
        var offset = d["target_offset"].getStr()
        var filter = fmt("loudnorm=I={targetLUFS}:LRA={targetRange}:TP={truePeak}:measured_I={measuredI}:measured_LRA={measuredLRA}:measured_tp={measuredTP}:measured_thresh={measuredThresh}:offset={offset}:{outputFormat}")
        var secondPassCmd = fmt("ffmpeg -i {inFile} -filter:a {filter} -ar {sampleRate} -c:a pcm_s32le {outFile}")
        discard os.execShellCmd(secondPassCmd)

when isMainModule:
    dispatch(entry,
        short = {
            "targetLUFS" : 't',
            "targetRange" : 'r',
            "truePeak" : 'p',
            "sampleRate" : 's',
            "verbose" : 'q'
        },
        help = {
            "input" : "Multiple files or a single file to process",
            "targetLUFS" : "Target LUFS",
            "targetRange" : "Target range",
            "truePeak" : "Maximum true peak",
            "sampleRate" : "Output sampling rate",
            "verbose" : "Do you want me to tell you what im thinking?"
        })
