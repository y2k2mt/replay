module Parrot
  class Handler 
    include HTTP::Handler

    def call(context)
      puts "Do something"
      call_next(context)
    end
  end
end
