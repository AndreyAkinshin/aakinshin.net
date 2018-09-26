---
layout: post
title: "Setting up build configuration in .NET"
date: "2014-02-08"
lang: en
type: post
tags:
- ".NET"
- MSBuild
- Configurations
redirect_from:
- /en/blog/dotnet/msbuild-configurations/
- /blog/post/msbuild-configurations/
---

You get two default build configurations: Debug and Release, when creating a new project in Visual Studio. And it’s enough for most small projects. But there can appear a necessity to extend it with the additional configurations. It’s ok if you need to add just a couple of new settings, but what if there are tens of such settings? And what if your solution contains 20 projects that need setting up of these configurations? In this case it becomes quite difficult to manage and modify build parameters.
 
In this article, we will review a way to make this process simpler by reducing description of the build configurations.<!--more-->

Open csproj file of one of your projects, you will find the following strings there:

``` xml
<PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
  <PlatformTarget>AnyCPU</PlatformTarget>
  <DebugSymbols>true</DebugSymbols>
  <DebugType>full</DebugType>
  <Optimize>false</Optimize>
  <OutputPath>bin\Debug\</OutputPath>
  <DefineConstants>DEBUG;TRACE</DefineConstants>
  <ErrorReport>prompt</ErrorReport>
  <WarningLevel>4</WarningLevel>
</PropertyGroup>
<PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|AnyCPU' ">
  <PlatformTarget>AnyCPU</PlatformTarget>
  <DebugType>pdbonly</DebugType>
  <Optimize>true</Optimize>
  <OutputPath>bin\Release\</OutputPath>
  <DefineConstants>TRACE</DefineConstants>
  <ErrorReport>prompt</ErrorReport>
  <WarningLevel>4</WarningLevel>
</PropertyGroup>
```

The first problem we face with is that the strings are duplicated (or almost duplicated) in all projects. Luckily, csproj files support export of configurations. So, let’s create the `Configurations.targets` file in the solution root folder. It will contain:

``` xml
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
    <PlatformTarget>AnyCPU</PlatformTarget>
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>
    <OutputPath>bin\Debug\</OutputPath>
    <DefineConstants>DEBUG;TRACE</DefineConstants>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|AnyCPU' ">
    <PlatformTarget>AnyCPU</PlatformTarget>
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>
    <OutputPath>bin\Release\</OutputPath>
    <DefineConstants>TRACE</DefineConstants>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup>
</Project>
```

After that you will be able to change the corresponding strings in the source csproj file to:

``` xml
<Import Project="..\Configurations.targets" />
```

Cool, we got rid of the duplicated configuration descriptions. Now we can focus on editing of a single file. You can notice that some strings are still duplicated in Debug and Release configurations. Assume that a developer wants to setup all these parameters individually for every configuration. If there is no such need, it’s possible to take the duplicated lines out to the common `PropertyGroup`:

``` xml
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <PlatformTarget>AnyCPU</PlatformTarget>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup> 

  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>
    <OutputPath>bin\Debug\</OutputPath>
    <DefineConstants>DEBUG;TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|AnyCPU' ">
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>
    <OutputPath>bin\Release\</OutputPath>
    <DefineConstants>TRACE</DefineConstants>
  </PropertyGroup>
</Project>
```

Is it possible to enhance anything else? Let’s think. The eye catches `OutputPath` which can be figured out from the configuration name. When you have two configurations you can set individual settings for each of them. But if you have quite a lot of configurations it would be great to make `OutputPath` figure out of the configuration name. Here we get the `$(Configuration)` variable that will help us to determine this name.

``` xml
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <!-- Common -->
  <PropertyGroup>
    <OutputPath>bin\$(Configuration)\</OutputPath>
    <PlatformTarget>AnyCPU</PlatformTarget>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup> 

  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>    
    <DefineConstants>DEBUG;TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|AnyCPU' ">
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>    
    <DefineConstants>TRACE</DefineConstants>
  </PropertyGroup>
</Project>
```

Great! We got rid of duplication. What else can be optimized? As a rule, the properties being set up depend only on the configuration; change of the platform doesn’t influence anything. Let’s remove this unnecessary condition.

``` xml
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <!-- Common -->
  <PropertyGroup>
    <OutputPath>bin\$(Configuration)\</OutputPath>
    <PlatformTarget>AnyCPU</PlatformTarget>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup> 

  <PropertyGroup Condition="'$(Configuration)' == 'Debug' ">
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>    
    <DefineConstants>DEBUG;TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)' == 'Release' ">
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>    
    <DefineConstants>TRACE</DefineConstants>
  </PropertyGroup>
</Project>
```

Now let’s add new configurations. Assume we want to add a Demo mode to the application. Not all features are available in this mode. The Demo mode may also require debugging that is why it’s reasonable to create `DebugDemo` and `ReleaseDemo` configurations. And, for example, we want to add a build mode that will require a user to use a license. We may also want to license Demo version. So, we have 4 more configurations: `DebugLicense`, `ReleaseLicense`, `DebugDemoLicense`, `ReleaseDemoLicense`. This situation is just a sample, your project can be absolutely different. `Demo` and `License` will add new variables to `DefineConstants`. It seems that you just need to create 8 separate `PropertyGroups` for 8 configurations. But something in my mind begins to protest. Luckily, you can add a more complicated condition than just comparison to the `Condition`. In this sample, we will search for the set substring in the configuration name:

``` xml
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <!-- Common -->
  <PropertyGroup>
    <OutputPath>bin\$(Configuration)\</OutputPath>
    <PlatformTarget>AnyCPU</PlatformTarget>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup> 

  <!-- Conditional -->
  <PropertyGroup Condition="$(Configuration.Contains('Debug'))">
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>    
    <DefineConstants>DEBUG;TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('Release'))">
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>    
    <DefineConstants>TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('License'))">
    <DefineConstants>$(DefineConstants);LICENSE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('Demo'))">
    <DefineConstants>$(DefineConstants);DEMO</DefineConstants>
  </PropertyGroup>  
</Project>
```

Looks quite good. There is a little problem: Visual Studio can’t get a list of available configurations. This issue can be solved by adding empty `PropertyGroups` with the same `Condition` as in the beginning. And you can add only those configurations you will actually use in your work. For example, we don’t want to debug `Demo` and `License` configurations. In this case we can write the following strings:

``` xml
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <!-- Common -->
  <PropertyGroup>
    <OutputPath>bin\$(Configuration)\</OutputPath>
    <PlatformTarget>AnyCPU</PlatformTarget>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup> 

  <!-- Conditional -->
  <PropertyGroup Condition="$(Configuration.Contains('Debug'))">
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>    
    <DefineConstants>DEBUG;TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('Release'))">
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>    
    <DefineConstants>TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('License'))">
    <DefineConstants>$(DefineConstants);LICENSE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('Demo'))">
    <DefineConstants>$(DefineConstants);DEMO</DefineConstants>
  </PropertyGroup>  

  <!-- Available -->
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|AnyCPU'" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Release|AnyCPU'" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'ReleaseDemo|AnyCPU'" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'ReleaseLicense|AnyCPU'" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'ReleaseDemoLicense|AnyCPU'" />
</Project>
```

If you’ve got the inborn hatred to duplication of anything, you can take out additional properties duplicated in all projects to the file you’ve got. For example, in this way:

``` xml
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <!-- Common -->
  <PropertyGroup>
    <Configuration Condition=" '$(Configuration)' == '' ">Release</Configuration>
    <Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>    
    <TargetFrameworkVersion>v4.0</TargetFrameworkVersion>
    <SolutionDir Condition="$(SolutionDir) == '' Or $(SolutionDir) == '*Undefined*'">..\</SolutionDir>
    <OutputPath>bin\$(Configuration)\</OutputPath>
    <PlatformTarget>AnyCPU</PlatformTarget>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup> 

  <!-- Conditional -->
  <PropertyGroup Condition="$(Configuration.Contains('Debug'))">
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>
    <DefineConstants>DEBUG;TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('Release'))">
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>
    <DefineConstants>TRACE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('License'))">
    <DefineConstants>$(DefineConstants);LICENSE</DefineConstants>
  </PropertyGroup>
  <PropertyGroup Condition="$(Configuration.Contains('Demo'))">
    <DefineConstants>$(DefineConstants);DEMO</DefineConstants>
  </PropertyGroup>  

  <!-- Available -->
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|AnyCPU'" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Release|AnyCPU'" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'ReleaseDemo|AnyCPU'" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'ReleaseLicense|AnyCPU'" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'ReleaseDemoLicense|AnyCPU'" />
</Project>
```

Now we got rid of all duplication for sure. And it’s so easy to setup configurations. I’d like to notice that this approach may not suit you; many projects are perfectly developed without editing of the configurations. And sometimes it’s necessary to setup each configuration for each project and for each platform manually – in this case you won’t be able to save your time by removing duplications. But if you’ve got a problem with setting up of quite a lot of configurations for quite a lot of projects, this practice may be a good fit. You can also get more information on build in MSDN.

## Links

* [MSBuild Reference](http://msdn.microsoft.com/en-us/library/0k6kkbsd.aspx)
* [MSBuild Conditional Constructs](http://msdn.microsoft.com/en-us/library/ms164307.aspx)
* [MSBuild Conditions](http://msdn.microsoft.com/en-us/library/7szfhaft.aspx)
* [Expand Property Functions](http://msdn.microsoft.com/en-us/library/dd633440.aspx)
* [How to: Use Environment Variables in a Build](http://msdn.microsoft.com/en-us/library/ms171459.aspx)
* [Common MSBuild Project Properties](http://msdn.microsoft.com/en-us/library/bb629394.aspx)
* [Common MSBuild Project Items](http://msdn.microsoft.com/en-us/library/bb629388.aspx)

## Cross-posts

* [blogs.perpetuumsoft.com](http://blogs.perpetuumsoft.com/dotnet/setting-up-build-configuration-in-net/)