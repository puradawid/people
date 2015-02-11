class TeamColor
  GOLDEN_RATIO_CONJUGATE = 0.618033988749895

  def as_rgb
    "#" + hsv_to_rgb(hue, 0.5, 0.95).join
  end

  private

  def hue
    (rand + GOLDEN_RATIO_CONJUGATE) % 1
  end

  def hsv_to_rgb(h, s, v)
    h_i = (h * 6).to_i
    f = h * 6 - h_i
    p = v * (1 - s)
    q = v * (1 - f * s)
    t = v * (1 - (1 - f) * s)
    case h_i
    when 0 then r, g, b = v, t, p
    when 1 then r, g, b = q, v, p
    when 2 then r, g, b = p, v, t
    when 3 then r, g, b = p, q, v
    when 4 then r, g, b = t, p, v
    when 5 then r, g, b = v, p, q
    end
    [r, g, b].map { |color| (color * 256).to_i.to_s(16) }
  end
end
