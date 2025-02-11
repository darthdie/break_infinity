part of infinity;

extension AddLayer on Infinity {
  //layeradd: like adding 'diff' to the number's slog(base) representation. Very similar to tetrate base 'base' and iterated log base 'base'.
  Infinity layerAdd(int diff, Infinity base) {
    logAbbreviation('layerAdd on ${toString()} diff: $diff base: $base');
    Infinity _result;

    final double sLogThis = slog(base).toNumber().toDouble();
    final double sLogDest = sLogThis + diff;

    if (sLogDest >= 0) {
      _result = tetrate(height: sLogDest, other: base);
    } else if (!sLogDest.isFinite) {
      _result = Infinity.nan();
    } else if (sLogDest >= -1) {
      _result = tetrate(height: sLogDest + 1, other: base).log(base);
    } else {
      _result = tetrate(height: sLogDest + 2, other: base).log(base).log(base);
    }

    return _result;
  }

  Infinity? layerAdd10(num value) {
    logAbbreviation('layerAdd10 on ${toString()} value: $value');
    num other = Infinity.fromNum(value).toNumber();
    Infinity? _result;

    final int layerAdd = other.truncate();
    other -= layerAdd;
    layer += layerAdd;

    if (other <= -1) {
      if (layer < 0) {
        for (int i = 0; i < 100; ++i) {
          layer++;
          mantissa = mantissa.log10();
          if (!mantissa.isFinite) {
            _result = this;
          }
          if (layer >= 0) {
            break;
          }
        }
      }
    }

    if (_result == null) {
      if (other != 0) {
        int subtractLayer = 0;
        //Ironically, this edge case would be unnecessary if we had 'negative layers'.
        while (mantissa.isFinite && mantissa < 10) {
          mantissa = math.pow(10, mantissa);
          ++subtractLayer;
        }

        //A^(10^B) === C, solve for B
        //B === log10(logA(C))

        if (mantissa > 1e10) {
          mantissa = mantissa.log10();
          layer++;
        }
        //layerAdd10: like adding 'other' to the number's slog(base) representation. Very similar to tetrate base 10 and iterated log base 10. Also equivalent to adding a fractional amount to the number's layer in its break_eternity.js representation.
        if (other > 0) {
          //Note that every integer slog10 value, the formula changes, so if we're near such a number, we have to spend exactly enough layerother to hit it, and then use the new formula.
          final num otherToNextSlog =
              (math.log(1e10) / math.log(mantissa)).log10();

          if (otherToNextSlog < other) {
            mantissa = 1e10.log10();
            layer++;
            other -= otherToNextSlog;
          }
        } else if (other < 0) {
          final num otherToNextSlog = (1 / mantissa.log10()).log10();

          if (otherToNextSlog > other) {
            mantissa = 1e10;
            layer--;
            other -= otherToNextSlog;
          }
        }

        mantissa = math.pow(mantissa, math.pow(10, other));

        while (subtractLayer > 0) {
          mantissa = mantissa.log10();
          --subtractLayer;
        }
      }

      while (layer < 0) {
        layer++;
        mantissa = mantissa.log10();
      }
      normalize();
    }

    return _result;
  }
}
