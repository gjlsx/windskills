from __future__ import annotations

import random


def bucket_sort(values: list[int], bucket_size: int = 50) -> list[int]:
    if not values:
        return []

    min_value = min(values)
    max_value = max(values)
    bucket_count = ((max_value - min_value) // bucket_size) + 1
    buckets: list[list[int]] = [[] for _ in range(bucket_count)]

    for value in values:
        bucket_index = (value - min_value) // bucket_size
        buckets[bucket_index].append(value)

    sorted_values: list[int] = []
    for bucket in buckets:
        if bucket:
            sorted_values.extend(sorted(bucket))

    return sorted_values


def main() -> None:
    random.seed(20260323)
    numbers = [random.randint(0, 999) for _ in range(100)]
    bucket_sorted = bucket_sort(numbers)
    expected = sorted(numbers)
    if bucket_sorted != expected:
        raise ValueError("Bucket sort output does not match built-in sorted output")

    print("Original values:")
    print(numbers)
    print()
    print("Bucket sorted values:")
    print(bucket_sorted)
    print()
    print("Validation: PASS")


if __name__ == "__main__":
    main()
