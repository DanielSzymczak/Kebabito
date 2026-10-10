extends Resource
class_name BigNumber

const MAX_ALIGN_DIFF := 15
const SNAP_PRECISION := 1e-12

@export var mantissa: float
@export var exponent: int

# --- Constructor ---
func _init(m: float = 0.0, e: int = 0):
	mantissa = m
	exponent = e
	_normalize()

# --- Factory helpers ---
static func from_int(value: int) -> BigNumber:
	if value == 0:
		return BigNumber.new(0.0, 0)
	var e := int(floor(log(value) / log(10)))
	var m := value / pow(10.0, e)
	return BigNumber.new(m, e)

static func from_float(value: float) -> BigNumber:
	if value == 0.0:
		return BigNumber.new(0.0, 0)
	var e := int(floor(log(abs(value)) / log(10)))
	var m := value / pow(10.0, e)
	return BigNumber.new(m, e)

# --- Core normalization ---
func _normalize():
	if mantissa == 0.0:
		exponent = 0
		return

	var number_sign := signf(mantissa)
	mantissa = abs(mantissa)

	while mantissa >= 10.0:
		mantissa /= 10.0
		exponent += 1

	while mantissa < 1.0:
		mantissa *= 10.0
		exponent -= 1

	mantissa *= number_sign
	mantissa = snapped(mantissa, SNAP_PRECISION)

func reset():
	mantissa = 0
	exponent = 0
	
# --- Arithmetic ---
func add(other: BigNumber) -> BigNumber:
	var res = self.clone()
	var diff : int= res.exponent - other.exponent
	
	if diff > MAX_ALIGN_DIFF:
		return res

	if diff < -MAX_ALIGN_DIFF:
		return other.clone()

	res.mantissa += other.mantissa * pow(10.0, -diff)
	res._normalize()
	return res

func subtract(other: BigNumber) -> BigNumber:
	var neg = other.clone()
	neg.mantissa *= -1.0
	return self.add(neg)


func pow_float(p: float) -> BigNumber:
	if is_zero():
		return BigNumber.new(0.0, 0)
	
	var new_mantissa = pow(abs(mantissa), p)
	var new_exponent_f = exponent * p
	
	var integer_exponent = int(floor(new_exponent_f))
	var fractional_exponent = new_exponent_f - integer_exponent
	
	var final_mantissa = new_mantissa * pow(10.0, fractional_exponent)
	
	if mantissa < 0 and int(p) % 2 != 0:
		final_mantissa *= -1
		
	return BigNumber.new(final_mantissa, integer_exponent)

func multiply(value: float) -> BigNumber:
	var copy = BigNumber.new(mantissa,exponent)
	copy.mantissa *= value
	copy._normalize()
	return copy

func multiply_big(other: BigNumber) -> BigNumber:
	var copy = BigNumber.new(mantissa,exponent)
	copy.mantissa *= other.mantissa
	copy.exponent += other.exponent
	copy._normalize()
	return copy

func divide(value: float) -> BigNumber:
	if value == 0.0:
		push_error("BigNumber: Division by zero float!")
		return BigNumber.new(0.0, 0)
	
	var copy = BigNumber.new(mantissa, exponent)
	copy.mantissa /= value
	copy._normalize()
	return copy

func divide_big(other: BigNumber) -> BigNumber:
	if other.is_zero():
		push_error("BigNumber: Division by zero BigNumber!")
		return BigNumber.new(0.0, 0)
	
	var copy = BigNumber.new(mantissa, exponent)
	copy.mantissa /= other.mantissa
	copy.exponent -= other.exponent
	copy._normalize()
	return copy

func modulo(other: BigNumber) -> BigNumber:
	if other.is_zero():
		push_error("BigNumber: Modulo by zero!")
		return BigNumber.new(0.0, 0)
	
	var division = self.divide_big(other)
	var division_floored = division.get_floored()
	var product = division_floored.multiply_big(other)
	return self.subtract(product)
	
# --- Utilities ---
func to_float() -> float:
	return mantissa * pow(10.0, exponent)
	
func floor_self() -> BigNumber:
	var value: float = to_float()
	var floored: float = floor(value)
	var bn := BigNumber.from_float(floored)
	mantissa = bn.mantissa
	exponent = bn.exponent
	return self
	
func clone() -> BigNumber:
	return BigNumber.new(mantissa, exponent)

func is_zero() -> bool:
	return mantissa == 0.0

func max(other: BigNumber) -> BigNumber:
	if self.is_greater(other):
		return self.clone()
	return other.clone()

func min(other: BigNumber) -> BigNumber:
	if self.is_less(other):
		return self.clone()
	return other.clone()

# --- Display ---
func format() -> String:
	var value := mantissa * pow(10.0, exponent)

	var idx := 0
	while value >= 1000.0:
		value /= 1000.0
		idx += 1

	var text: String
	if abs(value - round(value)) < 0.000001:
		text = str(int(round(value)))
	else:
		text = str(snapped(value, 0.01)).rstrip("0").rstrip(".")

	return "%s%s" % [text, get_suffix(idx)]

func format_time() -> String:
	var total_seconds := mantissa * pow(10.0, exponent)
	
	if total_seconds < 1.0 and total_seconds > 0:
		return "%.2fs" % total_seconds

	var seconds := int(total_seconds) % 60
	var minutes := int(total_seconds / 60.0) % 60
	var hours := int(total_seconds / 3600.0) % 24
	var days := int(total_seconds / 86400.0)
	
	if days > 0:
		return "%dd %dh %dm" % [days, hours, minutes]
	elif hours > 0:
		return "%dh %dm %ds" % [hours, minutes, seconds]
	elif minutes > 0:
		return "%dm %ds" % [minutes, seconds]
	else:
		return "%ds" % seconds

func is_greater(other: BigNumber) -> bool:
	if exponent != other.exponent:
		return exponent > other.exponent
	return mantissa > other.mantissa
	
func is_less(other: BigNumber) -> bool:
	if exponent != other.exponent:
		return exponent < other.exponent
	return mantissa < other.mantissa

func get_suffix(index: int) -> String:
	var base_suffixes = ["", "K", "M", "B", "T"]

	if index < base_suffixes.size():
		return base_suffixes[index]

	index -= base_suffixes.size()

	var result := ""
	while true:
		var char_code = int(index % 26)
		result = char(65 + char_code) + result
		@warning_ignore("integer_division")
		index = int(index / 26) - 1
		if index < 0:
			break

	return result

func get_floored() -> BigNumber:
	if exponent >= 15:
		return self.clone()
	
	var f = floor(to_float())
	return BigNumber.from_float(f)
