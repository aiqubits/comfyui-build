FROM nvidia/cuda:12.8.1-base-ubuntu22.04

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

ENV DEBIAN_FRONTEND=noninteractive

# Install os requirements
RUN apt-get update && \
    apt-get install -y curl software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y python3.12 tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12
    
#     git config --global http.postBuffer 5242880000 && \
#     git config --global http.sslVerify false && \
#     git config --global http.version HTTP/1.1 && \
#     git config --global http.sslBackend gnutls && \
#     git config --global init.defaultBranch main && \
#     git config --global http.sslBackend gnutls && \
#     git config --global filter.lfs.required true && \
#     git config --global filter.lfs.clean "git-lfs clean -- %f" && \
#     git config --global filter.lfs.smudge "git-lfs smudge -- %f" && \
#     git config --global filter.lfs.process "git-lfs filter-process"

# Install environment requirements
RUN python3.12 -m pip install --timeout=10000 torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu126

# Install pip requirements
RUN python3.12 -m pip install --timeout=10000 comfyui-frontend-package==1.11.8 torchsde \
    numpy>=1.25.0 einops transformers>=4.28.1 tokenizers>=0.13.3 sentencepiece safetensors>=0.4.2 \
    aiohttp>=3.11.8 yarl>=1.18.0 pyyaml Pillow scipy tqdm psutil kornia>=0.7.1 spandrel soundfile av

WORKDIR /app
COPY . /app

VOLUME [ "/models", "/app/models" ]

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

EXPOSE 8188

# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["python3.12", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
