class_name BrainComponent extends Node


const COUNT_INPUTS : int = 25  # 8 направлений × (проходимость + энергия + яд) + энергия агента
const COUNT_HIDDEN : int = 32   # Увеличено для лучшего обучения
const COUNT_OUTPUT : int = 8    # Только направления (без "стоять")

# Инициализация весов
var weights_to_hidden : Array = []
var weights_to_output : Array = []
var bias_hidden : Array = []
var bias_output : Array = []

func _ready():
	random_weights()

func random_weights() -> void:
	weights_to_hidden = []
	weights_to_output = []
	bias_hidden = []
	bias_output = []
	
	# Инициализация Xavier/Glorot для лучшей сходимости
	var hidden_std = sqrt(2.0 / float(COUNT_INPUTS + COUNT_HIDDEN))
	var output_std = sqrt(2.0 / float(COUNT_HIDDEN + COUNT_OUTPUT))
	
	# Веса скрытого слоя
	for i in COUNT_HIDDEN:
		var row : Array = []
		row.resize(COUNT_INPUTS)
		for c in COUNT_INPUTS:
			row[c] = randfn(0.0, hidden_std)
		weights_to_hidden.append(row)
		bias_hidden.append(randfn(0.0, hidden_std))
	
	# Веса выходного слоя
	for i in COUNT_OUTPUT:
		var row : Array = []
		row.resize(COUNT_HIDDEN)
		for c in COUNT_HIDDEN:
			row[c] = randfn(0.0, output_std)
		weights_to_output.append(row)
		bias_output.append(randfn(0.0, output_std))

func mutate_weights():
	# Мутация с вероятностью mutation_rate
	for i in COUNT_HIDDEN:
		for c in COUNT_INPUTS:
			weights_to_hidden[i][c] = clamp(weights_to_hidden[i][c] + randfn(0.0, 0.05), -1.0, 1.0)
		bias_hidden[i] = clamp(bias_hidden[i] + randfn(0.0, 0.05), -1.0, 1.0)
	
	for i in COUNT_OUTPUT:
		for c in COUNT_HIDDEN:
			weights_to_output[i][c] = clamp(weights_to_output[i][c] + randfn(0.0, 0.05), -1.0, 1.0)
		bias_output[i] = clamp(bias_output[i] + randfn(0.0, 0.05), -1.0, 1.0)

func predict(inputs : Array) -> int:
	if weights_to_hidden.is_empty() or weights_to_output.is_empty():
		return randi() % COUNT_OUTPUT  # Случайное направление если сеть не инициализирована
	
	# Проверка ввода
	if inputs.size() != COUNT_INPUTS:
		push_error("Неверный размер входных данных. Ожидается %d, получено %d" % [COUNT_INPUTS, inputs.size()])
		return 0
	
	# Прямое распространение с bias и ReLU
	var hidden_out : Array = []
	for i in COUNT_HIDDEN:
		var sum = bias_hidden[i]
		for j in COUNT_INPUTS:
			sum += weights_to_hidden[i][j] * inputs[j]
		hidden_out.append(max(0.0, sum))  # ReLU
	
	var output_out : Array = []
	for i in COUNT_OUTPUT:
		var sum = bias_output[i]
		for j in COUNT_HIDDEN:
			sum += weights_to_output[i][j] * hidden_out[j]
		output_out.append(1.0 / (1.0 + exp(-sum)))  # Sigmoid
	
	# Выбор направления с учётом проходимости
	var best_dir = 0
	var best_score = -INF
	for i in COUNT_OUTPUT:
		# Проверяем проходимость направления (первые 8 входов - проходимость)
		if i < 8 and inputs[i*3] < 0.5:  # Если проходимость < 0.5 (стена)
			continue
		
		if output_out[i] > best_score:
			best_score = output_out[i]
			best_dir = i
	
	return best_dir if best_score > -INF else 0  # Возвращаем 0 если все направления заблокированы

# Оптимизированная версия dot продукта
static func dot(a: Array, b: Array) -> Array:
	var result = []
	for i in range(a.size()):
		var sum = 0.0
		for j in range(b.size()):
			sum += a[i][j] * b[j]
		result.append(sum)
	return result
