part of infinity;

Infinity? _handlePentateString(String value) {
  //Handle x^^^y format.
  final pentationParts = value.split('^^^');
  if (pentationParts.length == 2) {
    final base = double.tryParse(pentationParts.first);
    double? height;
    double? payload = 1;

    final List<String> pentationHeightParts = pentationParts.last.split(';');

    if (pentationHeightParts.length == 2) {
      height = double.tryParse(pentationHeightParts.first);
      payload = double.tryParse(pentationHeightParts.last);

      if (payload == null || !payload.isFinite) {
        payload = 1;
      }
    } else {
      height = double.tryParse(pentationParts.last);
    }

    if (base != null && base.isFinite && height != null && height.isFinite) {
      return Infinity.fromNum(base)
          .pentate(height: height, other: Infinity.fromNum(payload));
    }
  }

  return null;
}

Infinity? _handleTetrateString(String value) {
  //Handle x^^y format.
  final List<String> tetrateParts = value.split('^^');
  if (tetrateParts.length == 2) {
    final base = double.tryParse(tetrateParts.first);
    double? height;
    double? payload = 1;

    final List<String> tetrateHeightParts = tetrateParts.last.split(';');

    if (tetrateHeightParts.length == 2) {
      height = double.tryParse(tetrateHeightParts.first);
      payload = double.tryParse(tetrateHeightParts.last);

      if (payload == null || !payload.isFinite) {
        payload = 1;
      }
    } else {
      height = double.tryParse(tetrateParts.last);
    }

    if (base != null && height != null && base.isFinite && height.isFinite) {
      return Infinity.fromNum(base)
          .tetrate(height: height, other: Infinity.fromNum(payload));
    }
  }

  return null;
}

Infinity? _handlePowString(String value) {
  //Handle x^y format.
  final List<String> tetrateParts = value.split('^');
  if (tetrateParts.length == 2) {
    final base = double.tryParse(tetrateParts.first);
    final height = double.tryParse(tetrateParts.last);

    if (base != null && height != null && base.isFinite && height.isFinite) {
      return Infinity.fromNum(base).pow(Infinity.fromNum(height));
    }
  }

  return null;
}

Infinity? _handlePtString(String value) {
  Infinity? _result;

  //handle X PT Y format.
  final ptParts = value.contains('pt') ? value.split('pt') : value.split('p');

  if (ptParts.length == 2) {
    final height = double.tryParse(ptParts.first);
    final _formated = ptParts.last.replaceAll('(', '').replaceAll(')', '');
    var payload = double.tryParse(_formated);

    if (payload == null || !payload.isFinite) {
      payload = 1;
    }

    if (height != null && height.isFinite) {
      _result = Infinity.fromNum(10)
          .tetrate(height: height, other: Infinity.fromNum(payload));
    }
  }

  return _result;
}

Infinity _handleEString(String value) {
  Infinity? _result;

  if (value.contains('e^')) {
    _result = _handleEPowFormat(value);
  } else {
    //handle X PT Y format.
    final eParts = value.split('e');
    final _eCount = eParts.length - 1;

    final mantissa = double.tryParse(eParts[0]) ?? 1.0;
    var exponent = double.parse(eParts[eParts.length - 1]);

    if (_eCount == 0) {
      final numberAttempt = double.tryParse(value);

      if (numberAttempt != null) {
        _result = Infinity.fromNum(numberAttempt);
      }
    } else if (_eCount == 1) {
      final numberAttempt =
          double.tryParse(eParts.first.isEmpty ? '1$value' : value);

      if (numberAttempt != null && numberAttempt != 0) {
        _result = Infinity.fromNum(numberAttempt);
      } else {
        _result = Infinity.fromComponents(
            mantissa.sign.toInt(), 1, exponent + mantissa.abs().log10());
      }
    } else {
      if (_eCount >= 2) {
        final double _v =
            double.tryParse(eParts[eParts.length - 2]) ?? double.nan;

        if (_v.isFinite) {
          exponent *= _v.sign;
          exponent += _v.magLog10();
        }
      }

      if (_result == null) {
        if (!mantissa.isFinite) {
          _result = Infinity.fromComponents(
              eParts[0] == '-' ? -1 : 1, _eCount, exponent);
        } else {
          if (_eCount == 2) {
            _result = Infinity.fromComponents(1, 2, exponent)
                .multiply(Infinity.fromNum(mantissa));
          } else {
            _result = Infinity.fromComponents(
                mantissa.sign.toInt(), _eCount, exponent);
          }
        }
      }
    }
  }

  _result ??= Infinity.zero();
  _result.normalize();

  return _result;
}

Infinity? _handleEPowFormat(String value) {
  final _newParts = value.split('e^');

  if (_newParts.length == 2) {
    int sign = 1;
    num? layer;
    num? mantissa;
    if (_newParts.first[0] == '-') {
      sign = -1;
    }

    String layerString = '';

    final _chars = _newParts[1].runes.toList(growable: false);

    void _processChar(int charCode) {
      if ((charCode >= 43 && charCode <= 57) || charCode == 101) {
        //is "0" to "9" or "+" or "-" or "." or "e" (or "," or "/")
        layerString += charCode.toString();
      } else {
        //we found the end of the layer count
        layer = double.tryParse(layerString);
        mantissa = double.tryParse(
            _newParts[1].substring(_chars.indexOf(charCode) + 1));
      }
    }

    _chars.forEach(_processChar);

    if (layer != null && mantissa != null) {
      return Infinity.fromComponents(sign, layer!, mantissa!);
    }
  }

  return null;
}
