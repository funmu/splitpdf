# SplitPDF implemented with Python

Python has a good helper utility **pdf2image** that is useful for converting PDF to images.

We will use this to implement the conversion process.
We will also use multiple thread option to check out the speedup.

```python

convert_from_path( inputPDF, output_folder, 
    dpi=300, fmt='png', output_file="page", thread_count=num_threads)

```

Ran the conversion with different thread counts. Here is the summary of results:

| Num Threads | Time Taken for conversion |
| ----------- | ------------------------- |
| 1 | 37.30 seconds |
| 2 | 24.53 seconds |
| 4 | 15.34 seconds |
| 8 |  9.32 seconds |
| 12 | 7.63 seconds |
| 16 | 6.68 seconds |

There is a good speed up when we use multiple threads, as long as there are cores to support the conversion.

An alternative method is to generate in-memory images and then write these down separately into files.
That method is memory intensive and IO process is all batched up without parallelism. So that can be slower.

## References

- [Convert to Images in Python](https://pypi.org/project/pdf2image/)
