FROM debian:testing as ismrmrd_stage1

LABEL maintainer="Timothy S. Phan <timothy.s.phan@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates locales
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

RUN mkdir -p /opt/code/siemens_to_ismrmrd

# Dependencies for the build
RUN apt-get install -y --no-install-recommends wget git pkg-config libhdf5-dev \
gcc make libfftw3-dev cmake liblapacke-dev g++ libpng-dev libopenblas-dev gfortran \
libhdf5-dev libxml2-dev libxslt1-dev libboost-dev libboost-program-options-dev \
libboost-system-dev libboost-filesystem-dev libboost-thread-dev libboost-timer-dev \
libboost-program-options-dev && \
apt-get clean && rm -rf /var/lib/apt/lists/*

# ISMRMRD library for vendor-neutral kspace files
RUN wget --quiet https://github.com/ismrmrd/ismrmrd/archive/refs/tags/v1.5.0.tar.gz && \
tar zxvf v1.5.0.tar.gz && cd ismrmrd-1.5.0 && mkdir build && cd build && cmake ../ && \
make && make install

# Sym-linking HDF5 shared objects
RUN cd /usr/lib/x86_64-linux-gnu && ln -s libhdf5_serial.so.103 libhdf5.so && \
ln -s libhdf5_serial_hl.so.100 libhdf5_hl.so && ln -s libhdf5_serial.so.103 libhdf5.so.103

WORKDIR /opt/code/siemens_to_ismrmrd
RUN git clone https://github.com/ismrmrd/siemens_to_ismrmrd.git

# siemens_to_ismrmrd converter
RUN cd /opt/code/siemens_to_ismrmrd/siemens_to_ismrmrd && \
    mkdir build && \
    cd build && \
    cmake ../ && \
    make && \
    make install

# Create archive of ISMRMRD libraries (including symlinks) for second stage
RUN cd /usr/local/lib && tar -czvf libismrmrd.tar.gz libismrmrd*

FROM debian:testing

RUN apt-get update && apt-get install -y --no-install-recommends libxslt1.1 libhdf5-103 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy siemens_to_ismrmrd from last stage and re-add necessary dependencies
COPY --from=ismrmrd_stage1 /usr/local/bin/siemens_to_ismrmrd  /usr/local/bin/siemens_to_ismrmrd
COPY --from=ismrmrd_stage1 /usr/local/lib/libismrmrd.tar.gz   /usr/local/lib/

RUN cd /usr/local/lib && tar -zxvf libismrmrd.tar.gz && rm libismrmrd.tar.gz && ldconfig

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

# Used for binding $PWD at runtime
VOLUME /project
WORKDIR /project

ENTRYPOINT ["siemens_to_ismrmrd"]