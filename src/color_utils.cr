require "raylib-cr"

module ColorUtils
  extend self

  def hsl_to_rgb(h : Float, s : Float, l : Float)
    if s == 0
      r = g = b = l # achromatic
    else
      q = l < 0.5 ? l * (1 + s) : l + s - l * s
      p = 2 * l - q

      r = hue_to_rgb(p, q, h + 1/3)
      g = hue_to_rgb(p, q, h)
      b = hue_to_rgb(p, q, h - 1/3)
    end

    Raylib::Color.new r: (r * 255).round, g: (g * 255).round, b: (b * 255).round, a: 255
  end

  def hue_to_rgb(p : Float, q : Float, t : Float)
    if t < 0
      t += 1
    end
    if t > 1
      t -= 1
    end

    if t < 1/6
      return p + (q - p) * 6 * t
    end
    if t < 1/2
      return q
    end
    if t < 2/3
      return p + (q - p) * (2/3 - t) * 6
    end

    return p
  end
end
