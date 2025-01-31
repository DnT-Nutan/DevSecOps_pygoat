# Use a specific version of Python with Debian Buster
FROM python:3.11.0b1-buster

# Set working directory in the container
WORKDIR /app

# Install dependencies for psycopg2 and other required packages
RUN apt-get update && apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev=11.16-0+deb10u1 \
    python3-dev=3.7.3-1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install pip and the necessary Python dependencies
RUN python -m pip install --no-cache-dir pip==22.0.4

# Copy requirements.txt and install the Python packages
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project files into the container
COPY . /app/

# Expose port for the application
EXPOSE 8000

# Run database migrations
RUN python3 /app/manage.py migrate

# Set the working directory to the pygoat app
WORKDIR /app/pygoat/

# Start the application using Gunicorn with specified settings
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
