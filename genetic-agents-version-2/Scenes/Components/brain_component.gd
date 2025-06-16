class_name BrainComponent extends Node

const TOTAL_INPUT : int = 8
const TOTAL_HIDDEN : int = 8
const TOTAL_OUTPUT : int = 8   

# Весовые коэффициенты
var weights_hidden : Array # Веса между входным и скрытым слоем (8x4)
var weights_output : Array # Веса между скрытым и выходным слоем (4x8)

# Параметры мутации
var mutation_rate : float = 0.1  # Вероятность мутации отдельного веса
var mutation_power : float = 0.5 # Сила изменения веса при мутации

# Инициализация перцептрона
func _init():
	randomize_weights()

# Случайная инициализация весов
func randomize_weights():
	weights_hidden.clear()
	weights_output.clear()
	
	for i in range(TOTAL_INPUT):
		var row : Array[float]
		for j in range(TOTAL_HIDDEN):
			row.append(randf_range(-1.0, 1.0))
		weights_hidden.append(row)
	
	for i in range(TOTAL_HIDDEN):
		var row : Array[float]
		for j in range(TOTAL_OUTPUT):
			row.append(randf_range(-1.0, 1.0))
		weights_output.append(row)
		
func activate(x : float) -> int:
	return x >= 0.5
	
func predict(inputs : Array) -> int:
	var hidden_sum = dot(self.weights_hidden, inputs)
	print(hidden_sum)
	
	
	
	return 0
	
func dot(a, b):
	# Если оба аргумента — одномерные массивы (векторы)
	if (a is Array) and (b is Array) and !(a[0] is Array) and !(b[0] is Array):
		if a.size() != b.size():
			push_error("Vectors must be of equal length Xd")
			return 0.0
		var result : float = 0.0
		for i in range(a.size()):
			result += a[i] * b[i]
		return result
	
	# Если первый аргумент — матрица (двумерный массив), а второй — вектор (одномерный)
	elif (a is Array) and (a[0] is Array) and (b is Array) and !(b[0] is Array):
		var rows : int = a.size()
		var cols : int = a[0].size()
		
		if cols != b.size():
			push_error("Matrix columns must match vector length Xd")
			return 0.0
		
		var result : Array[float] = []
		for i in range(rows):
			var sum : float = 0.0
			for j in range(cols):
				sum += a[i][j] * b[j]
				
			result.append(sum)
		return result
	
	else:
		push_error("Unsupported types for dot product")
		return 0.0
	
