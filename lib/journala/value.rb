module Journala
  class Value < BigDecimal
    def inspect
      if self < 0
        '-$%.2f' % (0 - to_f)
      else
        '$%.2f' % to_f
      end
    end
    
    def to_s
      inspect
    end

    def length
      inspect.length
    end
  end
end
