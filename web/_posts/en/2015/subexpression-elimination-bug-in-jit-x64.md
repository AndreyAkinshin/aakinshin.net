---
layout: post
title: "A bug story about JIT-x64"
date: "2015-02-27"
lang: en
type: post
tags:
- ".NET"
- C#
- JIT
- Bugs
redirect_from:
- /en/blog/dotnet/subexpression-elimination-bug-in-jit-x64/
- /blog/post/subexpression-elimination-bug-in-jit-x64/
---

Can you say, what will the following code display for `step=1`?

```cs
public void Foo(int step)
{
    for (int i = 0; i < step; i++)
    {
        bar = i + 10;
        for (int j = 0; j < 2 * step; j += step)
            Console.WriteLine(j + 10);
    }
}
```

If you think about specific numbers, you are wrong. The right answer: it depends. The post title suggests to us, the program can has a strange behavior for x64.<!--more-->

### The problem statement

The bug isn't a new one, it has been discussed a year ago on StackOverflow: [“JIT .Net compiler bug?”](http://stackoverflow.com/questions/20701701/jit-net-compiler-bug). However, the code from the question is too complicated for an analysis. I have tried to minimize it for the future examination. Let's consider the following code:

```cs
using System;
using System.Runtime.CompilerServices;

class Program
{
    static void Main()
    {
        new Program().Run();
    }

    private void Run()
    {
        Console.WriteLine("Optimization:");
        Optimization(1);
        Console.WriteLine("NoOptimization:");
        NoOptimization(1);
    }

    int bar;

    public void Optimization(int step)
    {
        for (int i = 0; i < step; i++)
        {
            bar = i + 10;
            for (int j = 0; j < 2 * step; j += step)
                Console.WriteLine(j + 10);
        }
    }

    [MethodImpl(MethodImplOptions.NoOptimization)]
    public void NoOptimization(int step)
    {
        for (int i = 0; i < step; i++)
        {
            bar = i + 10;
            for (int j = 0; j < 2 * step; j += step)
                Console.WriteLine(j + 10);
        }
    }
}
```

If you compile the code in the Release-x64 mode and run it with JIT-x64, you see the following result:

```
Optimization:
10
21
NoOptimization:
10
11
```

Unexpectedly, is not it? JIT-x64 has played a dirty trick on us and spent optimizing crooked. Some important facts:

* `step` is a method argument.
* Both of the loops start with zero and have the `step` increment..
* `j+10` prints on the Console, `i+10` stores in a local variable per each first loop iteration.

These conditions (and several tricky additional conditions) allows JIT-x64 to perform an sub-expression elimination optimization. Unfortunately he does it wrong.

### JIT-x86

At first, we will look to the assembler code for JIT-x86. We want to make sure that it is a code without any troubles.

```x86asm
; Optimization, JIT-x86
        for (int i = 0; i < step; i++)                
008400DA  in          al,dx                           
008400DB  push        edi                             
008400DC  push        esi                             
008400DD  push        ebx                             
008400DE  sub         esp,8                           
008400E1  mov         dword ptr [ebp-14h],ecx         
008400E4  mov         edi,edx                         ; edi=edx (edi=step)
008400E6  xor         edx,edx                         ; edx=0
008400E8  mov         dword ptr [ebp-10h],edx         ; [ebp-10h]=edx (i=0)
008400EB  test        edi,edi                         
008400ED  jle         00840125                        
        {                                             
            bar = i + 10;                             
008400EF  mov         eax,dword ptr [ebp-10h]         ; eax=[ebp-10h] (eax=i)
008400F2  add         eax,0Ah                         ; eax+=0Ah (eax=i+10)
008400F5  mov         edx,dword ptr [ebp-14h]         ; edx=&this
008400F8  mov         dword ptr [edx+4],eax           ; [edx+4]=eax (bar=i+10)
            for (int j = 0; j < 2 * step; j += step)  
008400FB  xor         esi,esi                         ; esi=0 (j=0)
008400FD  mov         ebx,edi                         ; ebx=edi (ebx=step)
008400FF  add         ebx,ebx                         ; ebx+=edx (ebx=2*step)
00840101  test        ebx,ebx                         
00840103  jle         0084011D                        
                Console.WriteLine(j + 10);            
00840105  call        72EE0258                        
0084010A  mov         ecx,eax                         
0084010C  lea         edx,[esi+0Ah]                   ; edx=[esi+0Ah] (edx=j+10)
0084010F  mov         eax,dword ptr [ecx]             
00840111  mov         eax,dword ptr [eax+38h]         
00840114  call        dword ptr [eax+14h]             ; Console.WriteLine(edx)
            for (int j = 0; j < 2 * step; j += step)  
00840117  add         esi,edi                         ; esi+=edi (j+=step)
00840119  cmp         esi,ebx                         ; if esi<ebx (j<2*step)
0084011B  jl          00840105                        ; jump to loop start (j)
        for (int i = 0; i < step; i++)                
0084011D  inc         dword ptr [ebp-10h]             ; [ebp-10h]++ (i++)
00840120  cmp         dword ptr [ebp-10h],edi         ; if [ebp-10h]<edi (i<step)
00840123  jl          008400EF                        ; jump to loop start (i)
00840125  lea         esp,[ebp-0Ch]                   
00840128  pop         ebx                             
00840129  pop         esi                             
0084012A  pop         edi                             
0084012B  pop         ebp                             
0084012C  ret                                         
```

The result is right, we can see the expected result on the Console:

```
Optimization:
10
11
NoOptimization:
10
11
```

### JIT-x64

Now, we will take the JIT-x64 assembler code and start with the `NoOptimization` method:

```x86asm
; NoOptimization, JIT-x64
        for (int i = 0; i < step; i++)                 
00007FFCC87202A5  mov         dword ptr [rsp+8],ecx    
00007FFCC87202A9  sub         rsp,38h                  
00007FFCC87202AD  mov         dword ptr [rsp+20h],0    ; [rsp+20h]=0 (i=0)
00007FFCC87202B5  mov         dword ptr [rsp+24h],0    ; [rsp+24h]=0 (j=0)
00007FFCC87202BD  mov         dword ptr [rsp+20h],0    ; [rsp+20h]=0 (i=0)
00007FFCC87202C5  jmp         00007FFCC8720316         
        {                                              
            bar = i + 10;                              
00007FFCC87202C7  mov         ecx,dword ptr [rsp+20h]  ; ecx=[rsp+20h] (ecx=i)
00007FFCC87202CB  add         ecx,0Ah                  ; ecx+=10 (ecx=i+10)
00007FFCC87202CE  mov         rax,qword ptr [rsp+40h]  ; rax=&this
00007FFCC87202D3  mov         dword ptr [rax+8],ecx    ; [rax+8]=ecx (bar=i+10)
            for (int j = 0; j < 2 * step; j += step)   
00007FFCC87202D6  mov         dword ptr [rsp+24h],0    ; [rsp+24h]=0 (j)
00007FFCC87202DE  jmp         00007FFCC87202FC         
                Console.WriteLine(j + 10);             
00007FFCC87202E0  mov         ecx,dword ptr [rsp+24h]  ; ecx=[rsp+24h] (ecx=j)
00007FFCC87202E4  add         ecx,0Ah                  ; ecx+=10
00007FFCC87202E7  call        00007FFD273DCF10         ; Console.WriteLine(j+10)
            for (int j = 0; j < 2 * step; j += step)   
00007FFCC87202EC  mov         r11d,dword ptr [rsp+48h] ; r11d=[rsp+48h] (r11d=step)
00007FFCC87202F1  mov         eax,dword ptr [rsp+24h]  ; eax=[rsp+24h] (eax=j)
00007FFCC87202F5  add         eax,r11d                 ; eax+=r11d (eax=j+step)
00007FFCC87202F8  mov         dword ptr [rsp+24h],eax  ; [rsp+24h]=eax (j=j+step)
00007FFCC87202FC  mov         eax,2                    ; eax=2
00007FFCC8720301  imul        eax,dword ptr [rsp+48h]  ; eax*=[rsp+48h] (eax=2*step)
00007FFCC8720306  cmp         dword ptr [rsp+24h],eax  ; if [resp+24h]<eax (j<2*step)
00007FFCC872030A  jl          00007FFCC87202E0         ; jump to loop start (j)
        for (int i = 0; i < step; i++)                 
00007FFCC872030C  mov         eax,dword ptr [rsp+20h]  ; eax=[rsp+20h] (i)
00007FFCC8720310  inc         eax                      ; eax++ (eax=i+1)
00007FFCC8720312  mov         dword ptr [rsp+20h],eax  ; [rsp+20h]=eax (i=i+1)
00007FFCC8720316  mov         eax,dword ptr [rsp+48h]  ; eax=[rsp+48h] (eax=step)
00007FFCC872031A  cmp         dword ptr [rsp+20h],eax  ; if [rsp+20h]<eax (i<step)
00007FFCC872031E  jl          00007FFCC87202C7         ; jump to loop start (i)
        }                                              
    }                                                  
00007FFCC8720320  jmp         00007FFCC8720322         
00007FFCC8720322  nop                                  
00007FFCC8720323  add         rsp,38h                  
00007FFCC8720327  ret                                  
```

Ok, it is fine, go to the opimized method:

```x86asm
; Optimization, JIT-x64
       for (int i = 0; i < step; i++)                 
00007FFCC87201C2  push        rsi                     
00007FFCC87201C3  push        rdi                     
00007FFCC87201C4  push        r12                     
00007FFCC87201C6  push        r13                     
00007FFCC87201C8  push        r14                     
00007FFCC87201CA  push        r15                     
00007FFCC87201CC  sub         rsp,28h                 
00007FFCC87201D0  mov         ebx,edx                 ; ebx=step
00007FFCC87201D2  mov         r12,rcx                 ; r12=&this
00007FFCC87201D5  lea         r15d,[rbx+0Ah]          ; r15d=rbx+10 (r15d=step+10)
00007FFCC87201D9  test        ebx,ebx                 
00007FFCC87201DB  jle         00007FFCC8720260        
00007FFCC87201E1  xor         esi,esi                 ; esi=0 (i=0)
00007FFCC87201E3  mov         edi,0Ah                 ; edi=10 ((i+10)=10)
            for (int j = 0; j < 2 * step; j += step)  
00007FFCC87201E8  mov         ebp,2                   ; ebp=2
00007FFCC87201ED  imul        ebp,ebx                 ; ebp*=ebx (ebp=2*step)
        {                                             
            bar = i + 10;                             
00007FFCC87201F0  mov         dword ptr [r12+8],edi   ; bar=edi
            for (int j = 0; j < 2 * step; j += step)  
00007FFCC87201F5  test        ebp,ebp                 
00007FFCC87201F7  jle         00007FFCC8720256        
00007FFCC87201F9  xor         r13d,r13d               ; r13d=0 (j=0)
00007FFCC87201FC  mov         r14d,0Ah                ; r14d=10                     // !!!
00007FFCC8720202  nop         word ptr [rax+rax]      
00007FFCC8720210  mov         rax,0FC2B841138h        
00007FFCC872021A  mov         rax,qword ptr [rax]     
00007FFCC872021D  test        rax,rax                 
00007FFCC8720220  jne         00007FFCC8720230        
00007FFCC8720222  mov         cl,1                    
00007FFCC8720224  call        00007FFD26C0D960        
00007FFCC8720229  nop         dword ptr [rax]         
00007FFCC8720230  mov         rcx,0FC2B841138h        
00007FFCC872023A  mov         rcx,qword ptr [rcx]     
00007FFCC872023D  mov         rax,qword ptr [rcx]     
00007FFCC8720240  mov         r8,qword ptr [rax+60h]  
00007FFCC8720244  mov         edx,r14d                ; edx=r14d                     // !!!
00007FFCC8720247  call        qword ptr [r8+28h]      ; Console.WriteLine(edx)       // !!!
00007FFCC872024B  add         r13d,ebx                ; r13d+=ebx (j+=step)
00007FFCC872024E  add         r14d,r15d               ; r14d+=r15d (r14d+=(step+10)) // !!!
00007FFCC8720251  cmp         r13d,ebp                ; if r13d<ebp (j<2*step)
00007FFCC8720254  jl          00007FFCC8720210        ; jump to loop start (j)
        for (int i = 0; i < step; i++)                
00007FFCC8720256  inc         esi                     ; esi++ (i++)
00007FFCC8720258  inc         edi                     ; edi++ ((i+10)++)
00007FFCC872025A  cmp         esi,ebx                 ; if esi<ebx (i<step)
00007FFCC872025C  jl          00007FFCC87201F0        ; jump to loop start (i)
00007FFCC872025E  xchg        ax,ax                   
00007FFCC8720260  add         rsp,28h                 
00007FFCC8720264  pop         r15                     
00007FFCC8720266  pop         r14                     
00007FFCC8720268  pop         r13                     
00007FFCC872026A  pop         r12                     
00007FFCC872026C  pop         rdi                     
00007FFCC872026D  pop         rsi                     
00007FFCC872026E  pop         rbp                     
00007FFCC872026F  pop         rbx                     
00007FFCC8720270  ret                                 
```

If you have some time to explore the above listing, you'll see that the problem is related with the `r14d` register which is used for output. At the beginning of the nested loop, it is initialized by `10`. Next, it increases by `step + 10` on each iteration (although the increment should be equal to `step`).

There is a [bug report](https://connect.microsoft.com/VisualStudio/feedback/details/812093/) in MS Connect about the issue. Unfortunately, the bug status is sad:

> Status: Closed as Won't Fix Won't Fix. Due to several factors the product team decided to focus its efforts on other items.

### RyuJIT

Let's download and install RyuJIT CTP5, set the `HKLM\SOFTWARE\Microsoft\.NETFramework\AltJit='*'` key in the regedit, and look to the x64 assembler code:

```x86asm
; Optimization, RyuJIT
        for (int i = 0; i < step; i++)                 
00007FFCC86F0160  push        r14                      
00007FFCC86F0162  push        rdi                      
00007FFCC86F0163  push        rsi                      
00007FFCC86F0164  push        rbp                      
00007FFCC86F0165  push        rbx                      
00007FFCC86F0166  sub         rsp,20h                  
00007FFCC86F016A  mov         rdi,rcx                  ; rdi=&this
00007FFCC86F016D  mov         esi,edx                  ; esi=edx (esi=step)
00007FFCC86F016F  xor         ebx,ebx                  ; ebx=0 (i=0)
00007FFCC86F0171  test        esi,esi                  
00007FFCC86F0173  jle         00007FFCC86F01AA         
00007FFCC86F0175  mov         ebp,esi                  ; ebp=esi (ebp=step)
00007FFCC86F0177  shl         ebp,1                    ; ebp*=2 (ebp=2*step)
        {                                              
            bar = i + 10;                              
00007FFCC86F0179  lea         eax,[rbx+0Ah]            ; eax=[rbx+0Ah] (eax=i+10)
00007FFCC86F017C  mov         dword ptr [rdi+8],eax    ; [rdi+8]=eax (bar=i+10)
            for (int j = 0; j < 2 * step; j += step)   
00007FFCC86F017F  xor         r14d,r14d                ; r14d=0 (j=0)
00007FFCC86F0182  test        ebp,ebp                  
00007FFCC86F0184  jle         00007FFCC86F01A4         
                Console.WriteLine(j + 10);             
00007FFCC86F0186  call        00007FFD26C0AFA0         
00007FFCC86F018B  mov         rcx,rax                  
00007FFCC86F018E  lea         edx,[r14+0Ah]            ; edx=r14+0Ah (edx=j+10)
00007FFCC86F0192  mov         rax,qword ptr [rax]      
00007FFCC86F0195  mov         rax,qword ptr [rax+60h]  
00007FFCC86F0199  call        qword ptr [rax+28h]      ; Console.WriteLine(edx)
            for (int j = 0; j < 2 * step; j += step)   
00007FFCC86F019C  add         r14d,esi                 ; r14d+=esi (j+=step)
00007FFCC86F019F  cmp         r14d,ebp                 ; if (r14d<ebp) (j<2*step)
00007FFCC86F01A2  jl          00007FFCC86F0186         ; jump to loop start (j)
        for (int i = 0; i < step; i++)                 
00007FFCC86F01A4  inc         ebx                      ; ebx++ (i++)
00007FFCC86F01A6  cmp         ebx,esi                  ; if ebx<esi (i<step)
00007FFCC86F01A8  jl          00007FFCC86F0179         ; jump to loop start (i)
00007FFCC86F01AA  add         rsp,20h                  
00007FFCC86F01AE  pop         rbx                      
00007FFCC86F01AF  pop         rbp                      
00007FFCC86F01B0  pop         rsi                      
00007FFCC86F01B1  pop         rdi                      
00007FFCC86F01B2  pop         r14                      
00007FFCC86F01B4  ret                                  
```

Everything is fine: clever optimization are absent, the code works correctly.

### Summary

The JIT-x86 and RyuJIT CTP5 don't have the described bug. However, it is exist in JIT-x64. Most likely, it will not going anywhere.

You should understand, there is no perfect software. .NET is not an exception. Bugs in the JIT are extremely rare, but it is useful to bear in mind that thay may exist.

### Links

* [StackOverflow: JIT .Net compiler bug?](http://stackoverflow.com/questions/20701701/jit-net-compiler-bug)
* [MS Connect: x64 jitter sub-expression elimination optimizer bug](https://connect.microsoft.com/VisualStudio/feedback/details/812093/x64-jitter-sub-expression-elimination-optimizer-bug)