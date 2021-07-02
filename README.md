# Quickstart

1. Create a file named `twix_to_ismrmrd` with the `docker run` command as below or just download the [`twix_to_ismrmrd`](https://github.com/CARDIAL-nyu/twix_to_ismrmrd/raw/main/twix_to_ismrmrd) file:

```bash
$ cat >twix_to_ismrmrd <<END_OF_SCRIPT
#!/bin/bash
docker run \
  --interactive --tty --rm \
  --volume "$PWD":/project \
  --workdir /project \
  --user $(id -u):$(id -g) \
  cardialnyu/twix_to_ismrmrd "$@"
END_OF_SCRIPT
```

2. Make it executable: `chmod +x twix_to_ismrmrd`

3. Loop through all the `*.dat` twix files in the current directory and convert them to ISMRMRD `.h5` format:
```bash
$ for f in *.dat; do ./twix_to_ismrmrd -f $f -o $f.h5 -Z -M ; done
```

4. (Optional) Move executable to a more central location and add to your `PATH`.
```bash
$ mkdir -p ~/opt/cardial/bin && mv twix_to_ismrmrd ~/opt/cardial/bin/ && echo "PATH=~/opt/cardial/bin:$PATH" >> ~/.bashrc
```

5. (Optional) Source your new bash init and call the `twix_to_ismrmrd` from anywhere:
```bash
$ source ~/.bashrc
$ twix_to_ismrmrd --help
Missing Siemens DAT filename
Allowed options:
  -h [ --help ]           Produce HELP message
  -v [ --version ]        Prints converter version and ISMRMRD version
  -f [ --file ]           <SIEMENS dat file>
  -z [ --measNum ]        <Measurement number>
  -Z [ --allMeas ]        <All measurements flag>
  -M [ --multiMeasFile ]  <Multiple measurements in single file flag>
  -m [ --pMap ]           <Parameter map XML>
  -x [ --pMapStyle ]      <Parameter stylesheet XSL>
  --user-map              <Provide a parameter map XML file>
  --user-stylesheet       <Provide a parameter stylesheet XSL file>
  -o [ --output ]         <ISMRMRD output file>
  -g [ --outputGroup ]    <ISMRMRD output group>
  -l [ --list ]           <List embedded files>
  -e [ --extract ]        <Extract embedded file>
  -X [ --debug ]          <Debug XML flag>
  -F [ --flashPatRef ]    <FLASH PAT REF flag>
  -H [ --headerOnly ]     <HEADER ONLY flag (create xml header only)>
  -B [ --bufferAppend ]   <Append protocol buffers>
  --studyDate             <User can supply study date, in the format of
                          yyyy-mm-dd>
```

# Note

This is heavily adapted from the official [Dockerfile](https://github.com/ismrmrd/siemens_to_ismrmrd/blob/494963cf600cd9838cdb9e6ca7f3b4cea98a94a3/Dockerfile) from the [siemens_to_ismrmrd](https://github.com/ismrmrd/siemens_to_ismrmrd) repository.  However, as of commit [`494963cf600cd9838cdb9e6ca7f3b4cea98a94a3`](https://github.com/ismrmrd/siemens_to_ismrmrd/commit/042209eb9fac54e2491835a0e0e8e5404068f50f), the build fails. 

This serves as the working *frozen* version that we will rely on for various automated MRI-related tasks.
