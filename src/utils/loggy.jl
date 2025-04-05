module Loggy

export print_vec, init_loggy

using Logging, LoggingExtras, Dates


function print_vec(v)
    return "["*join(round.(v, sigdigits=3),",")*"]"
end

function init_loggy()
    logger = FormatLogger(stdout) do io, args
        #print(io, args.level, " ")
        print(io, "[")
        Dates.format(io, now(), dateformat"HH:MM:SS.sss")
        print(io, "] ")
        #print(io, " [", args.file, ":", args.line, "] ")
        println(io, args.message)
    end
    logger = LevelOverrideLogger(Logging.Debug, logger) 
    global_logger(logger)
end


end # module Loggy
