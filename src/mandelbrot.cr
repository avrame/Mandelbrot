require "complex"
require "raylib-cr"
require "./color_utils"

module MandelbrotApp
  class Mandelbrot
    @@MAX_ITER = 64
    @@PLOT_X_START = -2.0
    @@PLOT_X_END = 0.5
    @@PLOT_Y_START = 1.0
    @@PLOT_Y_END = -1.0
    @@PLOT_WIDTH : Float64 = @@PLOT_X_START.abs + @@PLOT_X_END
    @@PLOT_HEIGHT : Float64 = @@PLOT_Y_START + @@PLOT_Y_END.abs
    @@PLOT_RATIO : Float64 = @@PLOT_HEIGHT / @@PLOT_WIDTH

    @win_width : Int32
    @win_height : Int32
    @texture : Raylib::Texture2D | Nil = nil

    def initialize(@width : Int32, @height : Int32)
      @win_width = @width
      @win_height = @height
      Raylib.init_window(@width, @height, "Mandelbrot")
      Raylib.set_window_state(Raylib::ConfigFlags::WindowResizable)
      Raylib.set_target_fps(60)

      generate()
    end

    def generate
      image = Raylib.gen_image_color(@width, @height, Raylib::BLACK)
      image_pointer = pointerof(image)
      (0).step(to: @width) do |img_x|
        (0).step(to: @height) do |img_y|
          plot_x = (img_x / @width) * @@PLOT_WIDTH + @@PLOT_X_START
          plot_y = (img_y / @height) * @@PLOT_HEIGHT - @@PLOT_Y_START
          iterations = iterate(Complex.new(plot_x, plot_y))
          scale = iterations / @@MAX_ITER
          color = scale == 1 ? ColorUtils.hsl_to_rgb(0.0, 0.0, 0.0) : ColorUtils.hsl_to_rgb(scale, 0.75, 0.5)
          Raylib.image_draw_pixel(image_pointer, img_x, img_y, color)
        end
      end
      @texture = Raylib.load_texture_from_image(image)
    end

    def iterate(c : Complex)
      z = 0
      n = 0
      while z.abs <= 2 && n < @@MAX_ITER
        z = z*z + c
        n += 1
      end
      n
    end

    def render
      if Raylib.window_resized?
        @win_width = Raylib.get_screen_width
        @win_height = Raylib.get_screen_height
        win_ratio = @win_height / @win_width
        if win_ratio >= @@PLOT_RATIO
          @width = @win_width
          @height = (@width * @@PLOT_RATIO).to_i32
        else
          @height = @win_height
          @width = (@height / @@PLOT_RATIO).to_i32
        end
        puts "@win_width: #{@win_width} @win_height: #{@win_height}"
        puts "@width: #{@width} @height: #{@height}"
        generate()
      end

      img_pos = Raylib::Vector2.new x: (@win_width - @width) / 2, y: (@win_height - @height) / 2
      if !@texture.nil?
        Raylib.draw_texture_v(@texture.not_nil!, img_pos, Raylib::WHITE)
      end
    end
  end
end
