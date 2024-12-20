def create_report(data):
    print(f"Name: {data['name']}")
    print(f"Age: {data['age']}")
    print(f"Department: {data['department']}")
    print(f"Salary: {data['salary']}")
    print(f"Bonus: {data['bonus']}")
    print(f"Performance Score: {data['performance_score']}")


# Пример использования:
data = {
    "name": "Шеповалов",
    "age": 21,
    "department": "Business",
    "salary": 1234567,
    "bonus": 654321,
    "performance_score": 100
}

create_report(data)