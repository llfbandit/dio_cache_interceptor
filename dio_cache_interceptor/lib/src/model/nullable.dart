class Nullable<T> {
  final T? _value;

  const Nullable(this._value);

  T? get value => _value;

  bool get isNotNull => _value != null;
}
