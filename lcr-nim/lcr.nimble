version       = "0.1.0"
author        = "James Bradbury"
description   = "Adjusts the volume of audio files using a two pass loudnorm filter from ffmpeg"
license       = "MIT"

srcDir = "src"
bin    = @["lcr"]

requires "nim >= 1.2.4"
requires "cligen"
requires "colorize"

#Manual buildRelease
task buildRelease, "Builds with -d:release and -d:danger":
    exec "nim c -d:release -d:danger --opt:speed --threads:on --outdir:./ ./src/lcr.nim"

#Manual installRelease
task installRelease, "Builds with -d:release and -d:danger and installs it in ~/.nimble/bin":
    exec "nimble install --passNim:-d:release --passNim:-d:danger --passNim:--opt:speed"

#Manual buildDebug
task buildDebug, "Builds without any optimisations and full stack traces":
    exec "nim c --stackTrace:on -x:on --opt:none --threads:on -o:./ ./src/lcr.nim"
