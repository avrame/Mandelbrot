require "raylib-cr"
require "./mandelbrot"

# TODO: Write documentation for `Mandelbrot`
module MandelbrotApp
  VERSION = "0.1.1"

  mandelbrot = Mandelbrot.new(800, 640)

  until Raylib.close_window?
    Raylib.begin_drawing
    Raylib.clear_background Raylib::BLACK
    mandelbrot.render
    Raylib.end_drawing
  end

  Raylib.close_window
end
