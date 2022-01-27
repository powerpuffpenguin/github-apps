# github-apps

[中文](README_zh.md)

This is a bash script to manage various open source applications installed from github.

You can create a configuration script for an open source application published on github, and then use this github-apps.sh to install, update, and uninstall it. When you have installed many open source projects on github, using github-apps.sh will make operations such as installation, update and uninstallation automated and organized. In addition, github-apps.sh can generate an autocomplete command script for bash_completion, so you can use tab completion Various command parameters.

* [why](#why)
    * [bash](#bash)
* [install](#install)
* [how](#how)
    * [completion](#completion)
    * [list](#list)
    * [install](#install)
    * [upgrade](#upgrade)
    * [remove](#remove)
    * [cache](#cache)
* [version](#version)
* [config script](#config_script)
    * [global variable](#global_variable)
    * [callback](#callback)
    * [other sources](#other_sources)

# why

There are a lot of useful and interesting open source projects on github, however one problem with using them is that they are usually not published in the operating system's package repositories, and different system platforms such as linux mac windows package managers are not the same. Even if they belong to linux, but redhat debian arch ... all use different package managers, it is difficult for you to ask open source projects without any source of profit to release corresponding packages for these platforms.

Even with so many problems, good open source projects are still coveted, so I decided to write a cross-platform tool to manage the installation, update and removal of these applications.

## bash

Regarding why bash is used, first of all, I don't like the syntax of bash, but the functions to be implemented are not too complicated, and bash is just enough. In addition, bash has some advantages over other languages, so I chose bash to implement it.

After consideration, I use bash mainly for the following reasons:

1. Cross-platform, mainstream systems can run.
2. The main reason is that most systems can run without additional dependencies. js or python will be easier to write code, but need to install additional runtime environment, I have multiple different environments like work machine (linux), home computer (linux), laptop (linux), game console (windows), router (openwrt), server (ubuntu), and some docker and virtualbox virtual machines, I want to use this management tool in all environments, but don't want to install something like nodejs or python in them all.
3. The configuration script needs to use a script. Using bash can make the configuration script also use bash, which makes the writing of the configuration script flexible and simple.

Of course, using bash also produces some problems such as:

1. Not very efficient, but much better than manual operation and the installation and update are automated, so a little slower is not a big problem.
2. The json data returned by github's api, bash does not have built-in json support, I use string matching to parse the data, if the subsequent github api returns the format change but it is unlikely, or the script is not parsed properly, the script may not work.

# install

This script uses curl to download the installation package and request the github api. Please refer to the [curl](https://curl.se/download.html) official website for installation.

To install to the default path (/usr/bin), execute the following command with root privileges:

```
curl -s  https://raw.githubusercontent.com/powerpuffpenguin/github-apps/main/install.sh | bash -s -- -n
```

> If it has already been installed, it will automatically exit the installation. To reinstall, you can use the -y parameter

To install to another path, you can use the -i or -install parameter to specify the installation path:

```
curl -s  https://raw.githubusercontent.com/powerpuffpenguin/github-apps/main/install.sh | bash -s -- -n -i ~/bin
```


# how

All commands and subcommands can be passed in `-h` to view the usage instructions. This script supports the following subcommands:

* [completion](#completion)
* [list](#list)
* [install](#install)
* [upgrade](#upgrade)
* [remove](#remove)
* [cache](#cache)
* [self](#self)

**Care** Most commands accept a `-t` test parameter. Use this parameter to test the workflow, it doesn't change the app just prints the changed flow. You can use it to keep track of printing information so that you can confirm how the system files will be modified before proceeding.

## completion

completionThe completion subcommand is used to generate command auto-completion code for bash. It is strongly recommended to use, if there is no automatic completion, then what is the difference between the linux shell and the salted fish of windows cmd😂. Enter the `-h` parameter to see a detailed description:
```
github-apps.sh completion -h
```

To make the current shell get autocomplete, you can execute the following command:
```
source <(github-apps.sh completion)
```

For *inux systems, you can execute the following command to make all newly opened shells get the autocomplete function:

```
github-apps.sh completion > /etc/bash_completion.d/github-app.sh
```

For MacOS, you can execute the following command to make all newly opened shells get autocomplete:

```
github-apps.sh completion > /usr/local/etc/bash_completion.d/github-app.sh
```

## list

The list command is used to list supported applications or installed applications. Enter the `-h` parameter to view detailed instructions:
```
github-apps.sh list -h
```


The list command without parameters will list all supported applications. If you want to add support for an application, you need to write a [config script](#config_script) for the application:
```
github-apps.sh list 
coredns
ariang
```

Passing in the `-v` parameter is used to display the version number of the locally installed application, and passing in the `-i` parameter is used to request that only locally installed applications be displayed:

```
github-apps.sh list -v
coredns v1.8.7
ariang
```

## install

The install command is used to install the application. Enter the `-h` parameter to view detailed instructions:

```
github-apps.sh install -h
```

install can accept multiple application names to be installed, the script will be installed in sequence. the following command will install two applications coredns and ariang:

```
github-apps.sh install coredns ariang
```

By default, install will find the last complete release from github to install. You can use the `-v` parameter to specify a version to install, but if you use the `-v` parameter, install can only accept one application to install. The following command will install the v1.2.0 version of coredns:

```
github-apps.sh install coredns -v v1.2.0
```

install will detect the locally installed version, if you already have a higher version of the application installed, you can also use the `install -v` parameter to downgrade to a lower version or force an upgrade to a mismatched incompatible higher version application. Feel free to try the `-v` parameter, because if the `-y` parameter is not used, install will ask you if you want to continue the installation before finding the version and performing the installation.

## upgrade

The upgrade command is used to upgrade installed applications, enter the `-h` parameter to view detailed instructions:

```
github-apps.sh upgrade -h
```

upgrade and install can accept multiple application names to be upgraded, and the script will perform the upgrade in sequence. At the same time, if you upgrade only one application, upgrade also supports the `-v` parameter, but upgrade cannot downgrade to a lower version application or upgrade to an incompatible higher version, so you can only use the install command. The following commands will upgrade both coredns and ariang:

```
github-apps.sh upgrade coredns ariang
```

It is worth mentioning that upgrade If you do not enter the application name, upgrade will detect the installed applications and perform the upgrade operation for them in turn.

```
github-apps.sh upgrade
```

## remove

When you no longer need an application, you can use remove to delete it, enter the `-h` parameter to see detailed instructions:

```
github-apps.sh remove -h
```
remove can also accept multiple application names to be deleted, and the script will execute the deletion in sequence. The following commands will remove both coredns and ariang:

```
github-apps.sh remove coredns ariang
```

**care** remove will not ask you again before removing, so be sure to execute this command only when you really want to remove it.

Usually remove will only delete the application, but keep the configuration file and data file of the application. For example, the configuration of mysql belongs to the configuration file, and the mysql database belongs to the data file. You can use the `-c` parameter to tell remove to delete the configuration files together, and the `-d` parameter to tell remove to also delete the data files. In addition, the `-a` command will specify to delete both configuration files and data files:

```
github-apps.sh remove coredns -a
```

**care** The actual deletion is done by the configuration script of the application. The configuration scripts provided by default follow the prompts of the `-c -d` parameters, but if you use a configuration script provided by a third party, you need to determine whether the configuration script follows This design requires.

## cache

install and upgrade will store the downloaded installation package in the github-apps.cache folder where github-app.sh is located. If all goes well, github-app.sh will automatically delete the used cache data. If an accident occurs You can also use the cache directive to view the cache and delete the cached data.

Also enter the `-h` parameter to view detailed instructions:

```
github-app.sh cache -h
```

The following command to check the size of the disk occupied by the cache:
```
github-app.sh cache
```

The following command clears the cache:
```
github-app.sh cache -d
```

## self

The self command is used to manage the github-apps.sh script itself. Enter the `-h` parameter to view detailed instructions:
```
github-apps.sh self -h
```

upgrade github-apps.sh:
```
github-apps.sh self -u
```

reinstall github-apps.sh:
```
github-apps.sh self -i
github-apps.sh self -i -v v1.1.0
```

remove github-apps.sh:
```
github-apps.sh self -r
github-apps.sh self -r -a
```

# version

Use semantic version numbers, support two forms:

* MAJOR.MINOR.PATCH
* vMAJOR.MINOR.PATCH

MAJOR MINOR PATCH is a positive integer, MAJOR is the major version number, only the same MAJOR will match when the application is upgraded. There is one exception to upgrade from MAJOR 0 to MAJOR 1.

# config_script

Different open source application installation configuration is different, in order to support them need to create **configuration script**. github-apps.sh is responsible for complex operations such as parsing the parameters passed in by the user, finding the application version and downloading it. The user needs to write a configuration script for the application to specify the installation path, decompress the compressed package to the disk, delete the disk and other operations.

The configuration script needs to be set to a bash script suffixed with .sh in the **github-apps.configure** folder of the path where github-apps.sh is located. github-apps.sh will use source to load the configure script.

You can refer to [built-in configuration script](https://github.com/powerpuffpenguin/github-apps/tree/main/bin/github-apps.configure) to implement your own configuration script, I recommend viewing [coredns.sh](https://github.com/powerpuffpenguin/github-apps/blob/main/bin/github-apps.configure/coredns.sh) This script has detailed comments, other built-in scripts may not have complete Notes

**care** The customized global variables and functions in the configuration script should not overwrite the variables or functions with the same name in github-apps.sh. It is recommended to use a customized name prefix. The following prefixes are safe and recommended:
* self
* this
* my
* conf

> There is no need to worry about name conflicts between multiple configuration scripts. github-apps.sh will source the configuration script before each invocation of the configuration script.

## global_variable

Several global variables are defined in github-apps.sh, and the configuration script and github-apps.sh need to communicate through these variables (who makes bash functions not even return values 😂)

|Variable|Type|Describe|
|--|--|--|
|FlagPlatformError  |string |   If the platform does not support the app, set the error description to this variable|
|FlagInstallDir|    string| installation path|
|FlagTest   | 0 or 1| If 1, the test executes |
|FlagVersion   | string| target version|
|FlagYes   | 0 or 1| If it is 1, automatically reply yes|
|FlagNo   | 0 or 1| If it is 1, automatically reply no|
|FlagSum | 0 or 1|    If it is 1, the checksum of the downloaded installation package needs to be detected|
|FlagDeleteConf| 0 or 1|    If 1, delete application configuration files|
|FlagDeleteData| 0 or 1|    If 1, delete application data files|
|FlagDownloadFile| string|    Application installation package download URL|
|FlagDownloadHash| string|    Installation package checksum download URL|
|FlagUrlLatest| string|    [github api: the URL of the get last released version](https://docs.github.com/en/rest/reference/releases#get-the-latest-release)|
|FlagUrlList| string|    [github api: the URL of the get version list](https://docs.github.com/en/rest/reference/releases#list-releases)|
|FlagUrlTag| string|    [github api: the URL of the get last released by tag](https://docs.github.com/en/rest/reference/releases#get-a-release-by-tag-name)|
|FlagKeep| 0 or 1|    if 1, keep (don't delete) download file|

## callback

In the configure script you need to implement some callback functions to help github-apps.sh do its work. github-apps.sh interacts with data through global variables and configuration scripts.

### AppsPlatform

This function will be the first function called, you should check whether the system platform supports it. If it is not supported, set the **FlagPlatformError** variable to non-null, so that github-apps.sh will output FlagPlatformError with an error message and end the work. Don't use echo output in this function, but set the error message to FlagPlatformError, because github-apps.sh will call AppsPlatform to check whether the application supports the current platform when it does not want to output the error message.

If the current platform supports the application, you need to set the application installation path to the **FlagInstallDir** variable.

### AppsSetUrl

This function will be called before installation or upgrade, you need to set **FlagUrlLatest** **FlagUrlList** **FlagUrlTag** three variables to tell github-apps.sh where to look for application version information.

In addition, you can check that **FlagVersion** is not empty, which means that the user has specified a version number. Only then do you need to set the **FlagUrlTag** variable.

### AppsSetFile

When a version of downloadable assets is found from github, this function will be called once for each asset, the first incoming parameter is the asset name, and the second incoming parameter is the download URL.

You need to determine whether it is the installation package of the current platform according to the asset name, if so, set the download URL to the variable **FlagDownloadFile**.

At the same time, if you find the checksum file, you can set its download URL to **FlagDownloadHash**, so that the checksum value of the download package will be detected before installation.

### AppsHash

AppsHash is optional.

If FlagDownloadHash is set and the user does not use the **--skip-checksum** parameter, AppsHash will be called to calculate the checksum. The first parameter of AppsHash is the path of the downloaded installation package. You need to calculate the checksum in it and output it. github-apps.sh will use the output value as the checksum.

The default implementation of AppsHash is to call `sha256sum "$1"` directly.

### AppsUnpack

The first incoming parameter of AppsUnpack is the path of the downloaded installation package. You need to unpack the compressed package in this function to install the application to the path specified by **FlagInstallDir**.

Remember to check the **FlagTest** variable before the actual installation of the application. If the variable is non-zero, it means that the user just wants to test it. Don't perform the real installation, you should just print the installation process.

### AppsRemove

AppsRemove callback is called when the app is removed, you should remove the app installed to the **FlagInstallDir** path in this function.

Remember to check the **FlagTest** variable before actually deleting the application. If the variable is non-zero, it means that the user just wants to test it. Don't execute the actual deletion, you should just print the deletion process.

### AppsVersion

AppsVersion is optional.

If the second parameter passed in is an empty string, the version number of the currently installed application needs to be returned to the variable **AppsVersionValue**.

If the second parameter passed in is a non-empty string, the second parameter is the version number of the app being installed, you need to persist it somewhere so that the version number can be returned later for github-apps.sh query.

When the AppsVersion function is not implemented, the default behavior is to create an apps.version file in the installation path specified by FlagInstallDir to record the application version number.

## other_sources

github-apps.sh can only support applications published on github by default, because it only parses the data returned by github api, but if there is another website that returns results similar to github api, github-apps.sh can also work. Additionally there are two callback functions that can be overridden in your config file to override the default github api request and parsing to support applications from additional origins:

* [AppsRequestVersion](#AppsRequestVersion)
* [AppsRequestVersionList](#AppsRequestVersionList)

## AppsRequestVersion

If the configure script provides this function it will replace the default version request, you need to use this function in:

1. According to the global variable **FlagVersion** If empty, find the full version information of the last release, if not empty, find the specified version information.
2. Call the `VersionNext "found version number"` function to set it, and judge that the return value **VersionNextOk** is 1 to confirm that the version number format is supported
3. Set the found version number into the variable **FlagVersion**
4. Set the package download URL to the **FlagDownloadFile** variable
5. If checksum exists and the **FlagSum** variable not 0, set the checksum download URL to the **FlagDownloadHash** variable

## AppsRequestVersionList

If provided through a configure script, this function is called to find the last upgradeable version when the last released version does not match the currently installed version. you need in this function:

1. Find the last upgradable version
2. Call the `VersionNext "found version number"` function to set it, and judge that the return value **VersionNextOk** is 1 to confirm that the version number format is supported
3. Set the found version number into the variable **FlagVersion**
4. Set the package download URL to the **FlagDownloadFile** variable
5. If checksum exists and the **FlagSum** variable not 0, set the checksum download URL to the **FlagDownloadHash** variable