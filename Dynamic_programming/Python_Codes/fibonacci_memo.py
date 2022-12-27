def fib_dp_algo(dictionary, serial_num):
    if serial_num <= 1:
        return serial_num, dictionary
    elif dictionary.get(serial_num) is not None:
        return dictionary.get(serial_num), dictionary
    else:
        temp_1, dictionary = fib_dp_algo(dictionary, serial_num - 1)
        temp_2, dictionary = fib_dp_algo(dictionary, serial_num - 2)
        dictionary[serial_num] = temp_1 + temp_2
        return dictionary.get(serial_num), dictionary
serial = float(input("Input your number: "))
print(type(serial))
fib_dict = {}
result, fib_dict = fib_dp_algo(fib_dict, serial)

print(int(result))
