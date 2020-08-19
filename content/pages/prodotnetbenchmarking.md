---
title: Pro .NET Benchmarking
url: /prodotnetbenchmarking/
---

<p></p>
<div class="container-fluid">
  <div class="row">
    <div class="col-sm">
      <img class="img-fluid" src="/img/misc/prodotnetbenchmarking-cover.png" />
    </div>
    <div class="col-md">
      <h3>Learn how to measure application performance and analyze the results!</h3>
      Use this in-depth guide to correctly design benchmarks, measure key performance metrics of .NET applications, and analyze results.
      This book presents dozens of case studies to help you understand complicated benchmarking topics.
      You will avoid common pitfalls, control the accuracy of your measurements, and improve performance of your software.
      Author Andrey Akinshin has maintained
        <a href="https://github.com/dotnet/BenchmarkDotNet">BenchmarkDotNet</a>
        (the most popular .NET library for benchmarking) for five years
        and covers common mistakes that developers usually make in their benchmarks.
      This book includes not only .NET-specific content but also essential knowledge about performance measurements
        which can be applied to any language or platform (common benchmarking methodology, statistics, and low-level features of modern hardware).
      With this book, you will learn:
      <ul>
        <li>Be aware of the best practices for writing benchmarks and performance tests</li>
        <li>Avoid the common benchmarking pitfalls</li>
        <li>Know the hardware and software factors that affect application performance</li>
        <li>Analyze performance measurements</li>
      </ul>
      <div class="text-center">
        <a class="btn btn-primary" href="https://www.apress.com/us/book/9781484249406">Apress</a>
        <a class="btn btn-primary" href="https://www.amazon.com/gp/product/1484249402/">Amazon US</a>
        <a class="btn btn-primary" href="https://www.amazon.ca/Pro-NET-Benchmarking-Performance-Measurement/dp/1484249402">Amazon CA</a>
        <a class="btn btn-primary" href="https://www.amazon.co.uk/Pro-NET-Benchmarking-Performance-Measurement/dp/1484249402">Amazon UK</a>
        <a class="btn btn-primary" href="https://www.amazon.de/dp/1484249402/">Amazon DE</a>
        <a class="btn btn-primary" href="https://www.amazon.fr/Pro-NET-Benchmarking-Performance-Measurement/dp/1484249402/">Amazon FR</a>
        <a class="btn btn-primary" href="https://www.amazon.es/Pro-NET-Benchmarking-Performance-Measurement/dp/1484249402/">Amazon ES</a>
        <a class="btn btn-primary" href="https://www.amazon.co.jp/Pro-NET-Benchmarking-Performance-Measurement/dp/1484249402/">Amazon JP</a>
        <a class="btn btn-primary" href="https://www.springer.com/gp/book/9781484249406">Springer</a>
        <a class="btn btn-primary" href="https://books.google.ru/books?id=IXCfDwAAQBAJ">Google Books</a>
        <a class="btn btn-primary" href="https://www.oreilly.com/library/view/pro-net-benchmarking/9781484249413/">O’Reilly</a>
        <a class="btn btn-primary" href="https://www.goodreads.com/book/show/45159905-pro-net-benchmarking">GoodReads</a>
        <a class="btn btn-primary" href="https://www.researchgate.net/publication/334047447_Pro_NET_Benchmarking_The_Art_of_Performance_Measurement">ResearchGate</a>
        <a class="btn btn-primary" href="https://github.com/Apress/pro-.net-benchmarking">GitHub (Examples)</a>
      </div>
    </div>
  </div>
</div>
<p></p>

## Content

The book contains nine chapters:

* **Chapter 1 “Introducing Benchmarking”**  
  This chapter contains some basic information about benchmarking and other performance investigations, including benchmarking goals and requirements. We will also discuss performance spaces and why it’s so important to analyze benchmark results.
* **Chapter 2 “Common Benchmarking Pitfalls”**  
  This chapter contains 15 examples of common mistakes that developers usually make during benchmarking. Each example is pretty small (so, you can easily understand what’s going on), but all of them demonstrate important problems and explain how to resolve them.
* **Chapter 3 “How Environment Affects Performance”**  
  This chapter explains why the environment is so important and introduces a lot of terms that will be used in subsequent chapters. You will find 12 case studies that demonstrate how minor changes in the environment may significantly affect application performance.
* **Chapter 4 “Statistics for Performance Engineers”**  
  This chapter contains the essential knowledge about statistics that you need during performance analysis. For each term,
  you will find practical recommendations that will help you use statistical metrics during your performance investigations. It also contains some statistical approaches that are really useful for benchmarking. At the end of this chapter, you will find different ways to lie with benchmarking: this knowledge will protect you from incorrect result interpretation.
* **Chapter 5 “Performance Analysis and Performance Testing”**  
  This chapter covers topics that you need to know if you want to control the performance level in a large product automatically. You will learn different kinds of performance tests, performance anomalies that you can observe, and how to protect yourself from these anomalies. At the end of this chapter, you will find a description of performance-driven development (an approach for writing performance tests) and a general discussion about performance culture.
* **Chapter 6 “Diagnostic Tools”**  
  This chapter contains a brief overview of different tools that can be useful during performance investigations.
* **Chapter 7 “CPU-Bound Benchmarks”**  
  This chapter contains 24 case studies that show different pitfalls in CPU-bound benchmarks. We will discuss some runtime- specific features like register allocation, inlining, and intrinsics; and hardware-specific features like instruction-level parallelism, branch prediction, and arithmetics (including IEEE 754).
* **Chapter 8 “Memory-Bound Benchmarks”**  
  This chapter contains 12 case studies that show different pitfalls in memory-bound benchmarks. We will discuss some runtime- specific features about garbage collection and its settings; and hardware-specific features like CPU cache and physical memory layout.
* **Chapter 9 “Hardware and Software Timers”**  
  This chapter contains all you need to know about timers. We will discuss basic terminology, different kinds of hardware timers, corresponding timestamping APIs on different operating systems, and the most common pitfalls of using these APIs. This chapter also contains a lot of “extra” content that you don’t actually need for benchmarking, but it may be interesting for people who want to learn more about timers.

## Table of content

* **Chapter 1 “Introducing Benchmarking”**
  * Planning a Performance Investigation
    * Define Problems and Goals
    * Pick Metrics
    * Select Approaches and Tools
    * Perform an Experiment to Get the Results
    * Complete the Analysis and Draw Conclusions
  * Benchmarking Goals
    * Performance Analysis
    * Benchmarks as a Marketing Tool
    * Scientific Interest
    * Benchmarking for Fun
  * Benchmark Requirements
    * Repeatability
    * Verifiability and Portability
    * Non-Invading Principle
    * Acceptable Level of Precision
    * Honesty
  * Performance Spaces
    * Basics
    * Performance Model
    * Source Code
    * Environment
    * Input Data
    * Distribution
    * The Space
  * Analysis
    * The Bad, the Ugly and the Good
    * Find Your Bottleneck
    * Statistics
  * Summary
* **Chapter 2 “Common Benchmarking Pitfalls”**
  * General Pitfalls
    * Inaccurate Timestamping
    * Executing a Benchmark in the Wrong Way
    * Natural Noise
    * Tricky Distributions
    * Measuring Cold Start instead of Warmed Steady State
    * Insufficient Number of Invocations
    * Infrastructure Overhead
    * Unequal Iterations
  * .NET-Specific Pitfalls
    * Loop Unrolling
    * Dead Code Elimination
    * Constant Folding
    * Bound Check Elimination
    * Inlining
    * Conditional Jitting
    * Interface Method Dispatching
  * Summary
* **Chapter 3 “How Environment Affects Performance”**
  * Runtime
    * .NET Framework
    * .NET Core
    * Mono
    * Case Study 1: StringBuilder and CLR Versions
    * Case Study 2: Dictionary and Randomized String Hashing
    * Case Study 3: IList.Count and Unexpected Performance Degradation
    * Case Study 4: Build Time and GetLastWriteTime Resolution
    * Summing Up
  * Compilation
    * IL Generation
    * Just-In-Time (JIT) Compilation
    * Ahead-Of-Time (AOT) Compilation
    * Case Study 1: Switch and C* Compiler Versions
    * Case Study 2: Params and Memory Allocations
    * Case Study 3: Swap and Unobvious IL
    * Case Study 4: Huge Methods and Jitting
    * Summing Up
  * External Environment
    * Operating System
    * Hardware
    * The Physical World
    * Case Study 1: Windows Updates and Changes in .NET Framework
    * Case Study 2: Meltdown, Spectre, and Critical Patches
    * Case Study 3: MSBuild and Windows Defender
    * Case Study 4: Pause Latency and Intel Skylake
    * Summing Up
  * Summary
* **Chapter 4 “Statistics for Performance Engineers”**
  * Descriptive Statistics
    * Basic Sample Plots
    * Sample Size
    * Minimum, Maximum, and Range
    * Mean
    * Median
    * Quantiles, Quartiles, and Percentiles
    * Outliers
    * Box Plots
    * Frequency Trails
    * Modes
    * Variance and Standard Deviation
    * Normal Distribution
    * Skewness
    * Kurtosis
    * Standard Error and Confidence Intervals
    * The Central Limit Theorem
    * Summing Up
  * Performance Analysis
    * Distribution Comparison
    * Regression Models
    * Optional Stopping
    * Pilot Experiments
    * Summing Up
  * How to Lie with Benchmarking
    * Lie with Small Samples
    * Lie with Percents
    * Lie with Ratios
    * Lie with Plots
    * Lie with Data Dredging
    * Summing Up
  * Summary
* **Chapter 5 “Performance Analysis and Performance Testing”**
  * Performance Testing Goals
    * Goal 1: Prevent Performance Degradations
    * Goal 2: Detect Not-Prevented Degradations
    * Goal 3: Detect Other Kinds of Performance Anomalies
    * Goal 4: Reduce Type I Error Rate
    * Goal 5: Reduce Type II Error Rate
    * Goal 6: Automate Everything
    * Summing Up
  * Kinds of Benchmarks and Performance Tests
    * Cold Start Tests
    * Warmed Up Tests
    * Asymptotic Tests
    * Latency and Throughput Tests
    * Unit and Integration Tests
    * Monitoring and Telemetry
    * Tests With External Dependencies
    * Other Kinds of Performance Tests
    * Summing Up
  * Performance Anomalies
    * Degradation
    * Acceleration
    * Temporal Clustering
    * Spatial Clustering
    * Huge Duration
    * Huge Variance
    * Huge Outliers
    * Multimodal Distributions
    * False Anomalies
    * Underlying Problems and Recommendations
    * Summing Up
  * Strategies of Defense
    * Pre-Commit Tests
    * Daily Tests
    * Retrospective Analysis
    * Checkpoints Testing
    * Pre-Release Testing
    * Manual Testing
    * Post-Release Telemetry and Monitoring
    * Summing Up
  * Performance Subpaces
    * Metric Subspace
    * Iteration Subspace
    * Test Subspace
    * Environment Subspace
    * Parameter Subspace
    * History Subspace
    * Summing Up
  * Performance Asserts and Alarms
    * Absolute Threshold
    * Relative Threshold
    * Adaptive Threshold
    * Manual Threshold
    * Summing Up
  * Performance-Driven Development (PDD)
    * Define a Task and Performance Goals
    * Write a Performance Test
    * Change the Code
    * Check the New Performance Space
    * Summing Up
  * Performance Culture
    * Shared Performance Goals
    * Reliable Performance Testing Infrastructure
    * Performance Cleanness
    * Personal Responsibility
    * Summing Up
  * Summary
* **Chapter 6 “Diagnostic Tools”**
  * BenchmarkDotNet
  * Visual Studio Tools
    * Embedded Profilers
    * Disassembly View
  * JetBrains Tools
    * dotPeek
    * dotTrace and dotMemory
    * ReSharper
    * Rider
  * Windows Sysinternals
    * RAMMap
    * VMMap
    * Process Monitor
  * Other Useful Tools
    * ildasm and ilasm
    * monodis
    * ILSpy
    * dnSpy
    * WinDbg
    * Asm-Dude
    * Mono Console Tools
    * PerfView
    * perfcollect
    * Process Hacker
    * Intel VTune Amplifier
  * Summary
* **Chapter 7 “CPU-Bound Benchmarks”**
  * Registers and Stack
    * Case Study 1: Struct Promotion
    * Case Study 2: Local Variables
    * Case Study 3: Try-Catch
    * Case Study 4: Number of Calls
    * Summing Up
  * Inlining
    * Case Study 1: Call Overhead
    * Case Study 2: Register Allocation
    * Case Study 3: Cooperative Optimizations
    * Case Study 4: The "starg" IL Instruction
    * Summing Up
  * Instruction-Level Parallelism
    * Case Study 1: Parallel Execution
    * Case Study 2: Data Dependencies
    * Case Study 3: Dependency Graph
    * Case Study 4: Extremely Short Loops
    * Summing Up
  * Branch Prediction
    * Case Study 1: Sorted and Unsorted Data
    * Case Study 2: Number of Conditions
    * Case Study 3: Minimum
    * Case Study 4: Patterns
    * Summing Up
  * Arithmetic
    * Case Study 1: Denormalized Numbers
    * Case Study 2: Math.Abs
    * Case Study 3: double.ToString
    * Case Study 4: Integer Division
    * Summing Up
  * Intrinsics
    * Case Study 1: Math.Round
    * Case Study 2: Rotate Bits
    * Case Study 3: Vectorization
    * Case Study 4: System.Runtime.Intrinsics
    * Summing Up
  * Summary
* **Chapter 8 “Memory-Bound Benchmarks”**
  * CPU Cache
    * Case Study 1: Memory Access Patterns
    * Case Study 2: Cache Levels
    * Case Study 3: Cache Associativity
    * Case Study 4: False Sharing
    * Summing Up
  * Memory Layout
    * Case Study 1: Struct Alignment
    * Case Study 2: Cache Bank Conflicts
    * Case Study 3: Cache Line Splits
    * Case Study 4: 4K Aliasing
    * Summing Up
  * Garbage Collector
    * Case Study 1: GC Modes
    * Case Study 2: Nursery Size in Mono
    * Case Study 3: Large Object Heaps
    * Case Study 4: Finalization
    * Summing Up
  * Summary
* **Chapter 9 “Hardware and Software Timers”**
  * Terminology
    * Time Units
    * Frequency Units
    * Main Components of a Hardware Timer
    * Ticks and Quantizing Errors
    * Basic Timer Characteristics
    * Summing Up
  * Hardware Timers
    * TSC
    * HPET and ACPI PM
    * History of Magic Numbers
    * Summing Up
  * OS Timestamping API
    * Timestamping API on Windows: System Timer
    * Timestamping API on Windows: QPC
    * Timestamping API on Unix
    * Summing Up
  * .NET Timestamping API
    * DateTime.UtcNow
    * Environment.TickCount
    * Stopwatch.GetTimestamp
    * Summing Up
  * Timestamping Pitfalls
    * Small Resolution
    * Counter Overflow
    * Time Components and Total Properties
    * Changes in Current Time
    * Sequential Reads
    * Summing Up
  * Summary

## Details

* **Title:** Pro .NET Benchmarking
* **Subtitle:** The Art of Performance Measurement
* **Author:** Andrey Akinshin
* **Publisher:**: Apress
* **Edition:** 1
* **Date:** June, 2019
* **Number of Pages:** 690
* **Number of Illustrations:** 65
* **Language:** English
* **Softcover ISBN-10:** 1484249402
* **Softcover ISBN-13:** 978-1-4842-4940-6
* **eBook ISBN-13:** 978-1-4842-4941-3
* **DOI:** 10.1007/978-1-4842-4941-3

**How to cite:**
Akinshin, Andrey.
*Pro .NET Benchmarking.*
Apress, 2019.

**BibTeX reference:**

```tex
@book{Akinshin2019,
  author    = {Akinshin, Andrey}, 
  title     = {Pro .NET Benchmarking},
  publisher = {Apress},
  year      = {2019},
  edition   = {1},
  pages     = {690},
  isbn      = {978-1-4842-4940-6},
  doi       = {10.1007/978-1-4842-4941-3}
}
```
