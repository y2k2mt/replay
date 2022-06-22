module Parrot
  class RecordingHandler
    include HTTP::Handler

    def call(context)
      puts "Do recording"
      call_next(context)
    end
  end
  class RepeatingHandler
    include HTTP::Handler

    def call(context)
      puts "Do repeating"
      call_next(context)
    end
  end
end
