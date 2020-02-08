FROM openkbs/jdk-mvn-py3-vnc

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

ARG INTELLIJ_VERSION=${INTELLIJ_VERSION:-ideaIC-2018.3.3}
ENV INTELLIJ_VERSION=${INTELLIJ_VERSION}

ARG IDEA_PRODUCT_NAME=${IDEA_PRODUCT_NAME:-IdeaIC2018}
ENV IDEA_PRODUCT_NAME=${IDEA_PRODUCT_NAME}

ARG IDEA_PRODUCT_VERSION=${IDEA_PRODUCT_VERSION:-3}
ENV IDEA_PRODUCT_VERSION=${IDEA_PRODUCT_VERSION}

## -- derived vars ---
ENV IDEA_INSTALL_DIR="${IDEA_PRODUCT_NAME}.${IDEA_PRODUCT_VERSION}"
ENV IDEA_CONFIG_DIR=".${IDEA_PRODUCT_NAME}.${IDEA_PRODUCT_VERSION}"
ENV IDEA_PROJECT_DIR="IdeaProjects"

#ENV SCALA_VERSION=2.12.4
#ENV SBT_VERSION=1.0.4

## ---- USER_NAME is defined in parent image: 
## ---- openkbs/jre-mvn-py3-x11 already ----
ENV USER_NAME=${USER_NAME:-developer}
ENV HOME=/home/${USER_NAME}
    
#########################################################
#### ---- Install IntelliJ IDE : MODIFY two lines below ----
#########################################################

USER ${USER_NAME}

WORKDIR ${HOME}

# https://download.jetbrains.com/idea/ideaIC-2018.3.3-no-jdk.tar.gz
ARG INTELLIJ_IDE_TAR=ideaIC-2019.3.2.tar.gz
#ARG INTELLIJ_IDE_TAR=${INTELLIJ_VERSION}-no-jdk.tar.gz
ARG INTELLIJ_IDE_DOWNLOAD_FOLDER=idea

## -- (Release build) --
RUN wget https://download.jetbrains.com/${INTELLIJ_IDE_DOWNLOAD_FOLDER}/${INTELLIJ_IDE_TAR} && \
    tar xvf ${INTELLIJ_IDE_TAR} && \
    mv idea-IC-* ${IDEA_INSTALL_DIR}  && \
    rm ${INTELLIJ_IDE_TAR}

## -- (Key Chain lib Intellij IDE complains needing this) --
#RUN sudo apt-get install libsecret-1-0 gnome-keyring -y

## -- (Local build) --
#COPY ${INTELLIJ_IDE_TAR} ./
#RUN tar xvf ${INTELLIJ_IDE_TAR} && \
#    mv idea-IC-* ${IDEA_INSTALL_DIR}  && \
#    rm ${INTELLIJ_IDE_TAR}
    
RUN mkdir -p \
    ${HOME}/${IDEA_PROJECT_DIR} \
    ${HOME}/${IDEA_CONFIG_DIR} 
    #chown -R ${USER_NAME}:${USER_NAME} ${HOME}

VOLUME ${HOME}/${IDEA_PROJECT_DIR}
VOLUME ${HOME}/${IDEA_CONFIG_DIR}

CMD "${HOME}/${IDEA_INSTALL_DIR}/bin/idea.sh"

ENV PRODUCT_EXE="${HOME}/${IDEA_INSTALL_DIR}/bin/idea.sh"

COPY ./wrapper_process.sh ${HOME}/

##################################
#### VNC ####
##################################
WORKDIR ${HOME}

USER ${USER}

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]

##################################
#### IntelliJ ####
##################################
WORKDIR ${WORKSPACE}

CMD "${HOME}/${IDEA_INSTALL_DIR}/bin/idea.sh"

