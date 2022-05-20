FROM nginx:mainline-alpine

LABEL maintainer="Michael Morrissey"
LABEL site="https://github.com/whobutsb/ragnabott-pool"
LABEL description="Docker Image for Acid Tourism Pool App. Laravel/node based."

ARG PHP_VERSION=8.1
ARG user
ARG uid

ENV TZ="America/Denver"
ENV DEBIAN_FRONTEND=noninteractive
ENV CONTAINER_ROLE=@{CONTAINER_ROLE:-APP}
ENV GITHUB_OAUTH_KEY=${GITHUB_OAUTH_KEY:-}

WORKDIR /var/www/html

#RUN apt update \
#    && apt-get install -y software-properties-common && add-apt-repository ppa:ondrej/php \
#    && apt-get update
#RUN apt install -y \
RUN apk add --update \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-imap \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-mbstring  \
    php${PHP_VERSION}-memcached  \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-sockets \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-pcov \
    php${PHP_VERSION}-pgsql \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-xdebug  \
    php${PHP_VERSION}-zip  \
    php-redis \
    # Extra
    curl \
    git \
    ffmpeg \
    libmcrypt-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    nano \
    neovim \
    tmux \
    #nginx \
    supervisor \
    zip \
    unzip \
    zsh \
    openssh-client \
    # php-fpm needs this  
    && mkdir /run/php \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    #configure nginx to run in the bg
    #&& ln -sf /dev/stdout /var/log/nginx/access.log \
    #&& ln -sf /dev/stderr /var/log/nginx/error.log

  

# OhMyZsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 

# Composer
# RUN curl -sS https://getcomposer.org/installer  | php -- --install-dir=/usr/bin --filename=composer  \
#  && echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> ~/.zshrc \
#  && if [ ${GITHUB_OAUTH_KEY} ]; then composer config --global github-oauth.github.com $GITHUB_OAUTH_KEY ;fi
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer


# Laravel Installer 
RUN composer global require laravel/installer && composer clear-cache    

# Node, NPM, Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt install -y nodejs && npm -g install yarn --unsafe-perm

# config files
COPY docker/start.sh /usr/local/bin/start
RUN chmod +x /usr/local/bin/start
COPY docker/config/php/php.ini /etc/php/${PHP_VERSION}/fpm/conf.d/ragnabott-php.ini
COPY docker/config/nginx/ragnabott.conf /etc/nginx/sites-available/ragnabott.conf
RUN ln -s /etc/nginx/sites-available/ragnabott.conf /etc/nginx/sites-enabled/ragnabott.conf

# create the user
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
  chown -R $user:$user /home/$user

# Set the working dir
WORKDIR /var/www
USER $user
#nginx, node, laravel dusk
EXPOSE 8080 8000 80 443 3000 3001 9515 9773 

CMD /usr/local/bin/start