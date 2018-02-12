FROM ubuntu:16.04

MAINTAINER Anton Malinskiy "anton@malinskiy.com"

# TODO: Add your keychain for signing the app
# Make JRE aware of container limits
COPY ./container-limits /
# Set up insecure default adb key
COPY adb/* /root/.android/

ENV LINK_ANDROID_SDK=https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    GRADLE_VERSION=4.1 \
    GRADLE_HOME="/opt/gradle-4.1/bin" \
    ANDROID_HOME=/opt/android-sdk-linux \
    PATH="$PATH:/usr/local/rvm/bin:/opt/android-sdk-linux/tools:/opt/android-sdk-linux/platform-tools:/opt/android-sdk-linux/tools/bin:/opt/android-sdk-linux/emulator:/opt/gradle-4.1/bin"

RUN dpkg --add-architecture i386 && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt xenial main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -yq libstdc++6:i386 zlib1g:i386 libncurses5:i386 git mercurial curl ca-certificates unzip git-extras zip software-properties-common apt-transport-https locales --no-install-recommends && \
    apt-get clean && \
    locale-gen en_US.UTF-8

# Install OpenJDK 8 (or replace this with your choice of JDK)
RUN apt-get update && \
    apt-get install -yq openjdk-8-jdk --no-install-recommends && \
    apt-get clean

# Install stf-client
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
    curl -sSL https://get.rvm.io | grep -v __rvm_print_headline | bash -s stable --ruby && \
    echo "source /usr/local/rvm/scripts/rvm" >> ~/.bashrc && \
    git clone https://github.com/tseglevskiy/stf-client.git && \
    cd stf-client && \
    /bin/bash -l -c "gem build stf-client.gemspec" && \
    /bin/bash -l -c "gem install stf-client*gem" && \
    cd .. && \
    rm -rf stf-client

# Install Android SDK
RUN curl -sSL $LINK_ANDROID_SDK > /tmp/android-sdk-linux.zip && \
    unzip /tmp/android-sdk-linux.zip -d /opt/android-sdk-linux/ && \
    rm /tmp/android-sdk-linux.zip && \
    sdkmanager --update && \
    yes | sdkmanager --licenses && \
    sdkmanager \
      tools \
      platform-tools \
      "platforms;android-26" \
      "build-tools;26.0.2" \
      --verbose && \
    unset ANDROID_NDK_HOME && \
    # Unfilter devices
    curl -sSL -o /root/.android/adb_usb.ini https://raw.githubusercontent.com/apkudo/adbusbini/master/adb_usb.ini

# Install Gradle
RUN cd /opt && \
    curl -fl -sSL https://downloads.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip -o gradle-bin.zip && \
    unzip -q "gradle-bin.zip" && \
    rm "gradle-bin.zip" && \
    mkdir -p ~/.gradle && \
    echo "org.gradle.daemon=false\norg.gradle.parallel=true\norg.gradle.configureondemand=true" > ~/.gradle/gradle.properties

# Add STF init script
COPY ./setup-stf.sh /etc/profile.d/stf.sh
RUN echo "source /etc/profile.d/stf.sh" >> ~/.bashrc

# TODO: Install the CI agent and run it by default
