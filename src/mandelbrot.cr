require "complex"
require "raylib-cr"
require "./color_utils"

# TODO: Write documentation for `Mandelbrot`
module Mandelbrot
  extend self
  VERSION         = "0.1.0"
  MAX_ITER        =   64
  INIT_WIN_WIDTH  =  800
  INIT_WIN_HEIGHT =  640
  PLOT_X_START    = -2.0
  PLOT_X_END      =  0.5
  PLOT_Y_START    =  1.0
  PLOT_Y_END      = -1.0
  PLOT_WIDTH      = PLOT_X_START.abs + PLOT_X_END
  PLOT_HEIGHT     = PLOT_Y_START + PLOT_Y_END.abs
  PLOT_RATIO      = PLOT_HEIGHT / PLOT_WIDTH

  def iterate(c)
    z = 0
    n = 0
    while z.abs <= 2 && n < MAX_ITER
      z = z*z + c
      n += 1
    end
    n
  end

  Raylib.init_window(INIT_WIN_WIDTH, INIT_WIN_HEIGHT, "Mandelbrot")
  Raylib.set_window_state(Raylib::ConfigFlags::WindowResizable)
  Raylib.set_target_fps(60)

  def gen_mandelbrot_image(img_pointer, width, height)
    (0).step(to: width) do |window_x|
      (0).step(to: height) do |window_y|
        plot_x = (window_x / width) * PLOT_WIDTH + PLOT_X_START
        plot_y = (window_y / height) * PLOT_HEIGHT - PLOT_Y_START
        iterations = iterate(Complex.new(plot_x, plot_y))
        scale = iterations / MAX_ITER
        color = scale == 1 ? ColorUtils.hsl_to_rgb(0.0, 0.0, 0.0) : ColorUtils.hsl_to_rgb(scale, 0.75, 0.5)
        Raylib.image_draw_pixel(img_pointer, window_x, window_y, color)
      end
    end
  end

  win_width = image_width = INIT_WIN_WIDTH
  win_height = image_height = INIT_WIN_HEIGHT

  image = Raylib.gen_image_color(INIT_WIN_WIDTH, INIT_WIN_HEIGHT, Raylib::BLACK)
  image_ptr = pointerof(image)
  gen_mandelbrot_image(image_ptr, image_width, image_height)
  texture = Raylib.load_texture_from_image(image)

  until Raylib.close_window?
    Raylib.begin_drawing
    Raylib.clear_background Raylib::BLACK

    if Raylib.window_resized?
      win_width = Raylib.get_screen_width
      win_height = Raylib.get_screen_height
      if win_width <= win_height
        image_width = win_width
        image_height = win_width * PLOT_RATIO
      else
        image_height = win_height
        image_width = image_height / PLOT_RATIO
      end

      image = Raylib.gen_image_color(image_width, image_height, Raylib::BLACK)
      image_ptr = pointerof(image)
      gen_mandelbrot_image(image_ptr, image_width, image_height)
      texture = Raylib.load_texture_from_image(image)
    end

    img_pos = Raylib::Vector2.new x: (win_width - image_width) / 2, y: (win_height - image_height) / 2
    Raylib.draw_texture_v(texture, img_pos, Raylib::WHITE)

    Raylib.end_drawing
  end

  Raylib.close_window
end
