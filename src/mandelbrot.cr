require "complex"
require "raylib-cr"
require "./color_utils"

alias Rl = Raylib

module MandelbrotApp
  class Mandelbrot
    @@MAX_ITER = 64
    @@INIT_PLOT_X_START = -2.0
    @@INIT_PLOT_X_END = 0.5
    @@INIT_PLOT_Y_START = 1.0
    @@INIT_PLOT_Y_END = -1.0

    @win_width : Int32
    @win_height : Int32
    @texture : Rl::Texture2D | Nil = nil
    @plot_x_start : Float64 = @@INIT_PLOT_X_START
    @plot_x_end : Float64 = @@INIT_PLOT_X_END
    @plot_y_start : Float64 = @@INIT_PLOT_Y_START
    @plot_y_end : Float64 = @@INIT_PLOT_Y_END
    @plot_width : Float64
    @plot_height : Float64
    @plot_ratio : Float64
    @zoom_rect_width : Float64
    @zoom_rect_height : Float64

    def initialize(@width : Int32, @height : Int32)
      @win_width = @width
      @win_height = @height
      @plot_width = @plot_x_start.abs + @plot_x_end
      @plot_height = @plot_y_start + @plot_y_end.abs
      @plot_ratio = @plot_height / @plot_width
      @zoom_rect_width = @width / 10
      @zoom_rect_height = @height / 10
      Rl.init_window(@width, @height, "Mandelbrot")
      Rl.set_window_state(Rl::ConfigFlags::WindowResizable)
      Rl.set_target_fps(60)
      generate
    end

    def generate
      image = Rl.gen_image_color(@width, @height, Rl::BLACK)
      image_pointer = pointerof(image)
      (0).step(to: @width) do |img_x|
        (0).step(to: @height) do |img_y|
          plot_x = (img_x / @width) * @plot_width + @plot_x_start
          plot_y = (img_y / @height) * @plot_height - @plot_y_start
          iterations = iterate(Complex.new(plot_x, plot_y))
          scale = iterations / @@MAX_ITER
          color = scale == 1 ? ColorUtils.hsl_to_rgb(0.0, 0.0, 0.0) : ColorUtils.hsl_to_rgb(scale, 0.75, 0.5)
          Rl.image_draw_pixel(image_pointer, img_x, img_y, color)
        end
      end
      @texture = Rl.load_texture_from_image(image)
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
      if Rl.window_resized?
        @win_width = Rl.get_screen_width
        @win_height = Rl.get_screen_height
        win_ratio = @win_height / @win_width
        if win_ratio >= @plot_ratio
          @width = @win_width
          @height = (@width * @plot_ratio).to_i32
        else
          @height = @win_height
          @width = (@height / @plot_ratio).to_i32
        end
        generate
      end

      img_pos = Rl::Vector2.new x: (@win_width - @width) / 2, y: (@win_height - @height) / 2
      if !@texture.nil?
        Rl.draw_texture_v(@texture.not_nil!, img_pos, Rl::WHITE)
      end

      plot_x_0 = (@plot_x_start.abs / @plot_width) * @width
      Rl.draw_line plot_x_0, 0, plot_x_0, @height, Rl::WHITE
      plot_y_0 = (@plot_y_start / @plot_height) * @height
      Rl.draw_line 0, plot_y_0, @width, plot_y_0, Rl::WHITE

      mouse_x = Rl.get_mouse_x
      mouse_y = Rl.get_mouse_y
      mouse_scroll = Rl.get_mouse_wheel_move_v
      if mouse_scroll.y != 0
        @zoom_rect_width += 5 * mouse_scroll.y
        @zoom_rect_height = @zoom_rect_width * @plot_ratio
      end

      if Rl.mouse_button_pressed?(0)
        resize_plot(mouse_x, mouse_y)
      end
      Rl.draw_rectangle_lines(mouse_x, mouse_y, @zoom_rect_width, @zoom_rect_height, Rl::WHITE)

      # spacebar pressed
      if Rl.key_pressed?(32)
        reset_plot
      end
    end

    def resize_plot(mouse_x, mouse_y)
      @plot_x_end = @plot_x_start + @plot_width * ((mouse_x + @zoom_rect_width) / @width)
      @plot_x_start = @plot_x_start + @plot_width * (mouse_x / @width)
      @plot_y_end = -@plot_height * ((mouse_y - @zoom_rect_height) / @height) + @plot_y_start
      @plot_y_start = -@plot_height * (mouse_y / @height) + @plot_y_start
      @plot_width = (@plot_x_end - @plot_x_start).abs
      @plot_height = (@plot_y_end - @plot_y_start).abs
      @plot_ratio = @plot_height / @plot_width
      puts "start = #{@plot_x_start}, #{@plot_y_start}"
      puts "end = #{@plot_x_end}, #{@plot_y_end}"
      puts "width = #{@plot_width}"
      puts "height = #{@plot_height}"
      generate
    end

    def reset_plot
      @plot_x_start = @@INIT_PLOT_X_START
      @plot_x_end = @@INIT_PLOT_X_END
      @plot_y_start = @@INIT_PLOT_Y_START
      @plot_y_end = @@INIT_PLOT_Y_END
      @plot_width = @plot_x_start.abs + @plot_x_end
      @plot_height = @plot_y_start + @plot_y_end.abs
      @plot_ratio = @plot_height / @plot_width
      generate
    end
  end
end
