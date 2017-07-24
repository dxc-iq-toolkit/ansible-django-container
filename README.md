# ansible-django-container

Adds a Gunicorn-powered Django service to your [Ansible Container](https://github.com/ansible/ansible-container) project. Run the following commands
to install the service:

```
# Set the working directory to your Ansible Container project root
$ cd myproject

# Install the service
$ ansible-container install marcusianlevine.ansible-django-container
```

## Requirements

- [Ansible Container](https://github.com/ansible/ansible-container)
- An existing Ansible Container project. To create a project, simply run the following:
    ```
    # Create an empty project directory
    $ mkdir myproject

    # Set the working directory to the new directory
    $ cd myproject

    # Initialize the project
    $ ansible-contiainer init
    ```

- By default, this role creates a user within the container named "django". During deployment, the container entrypoint process should be run as this user.
- Your django project's requirements.txt **must contain gunicorn**.
- In addition to running collectstatic and embedding your static files in the resulting Docker image, this role also supports transferring your static files to e.g. an nginx container via docker volumes.
    - This behavior is achieved by copying the static files to the conductor, so they can then be copied to any other container built by the same ansible-container pipeline

## Role Variables

Note: to help keep the difference between Ansible and Environment variables straight, variables in the Ansible context will be lower case (this_is_ansible), while Environment variables will always be capitalized (ENVIRONMENT_VARIABLE).

### Ansible Role Variables

These variables can be overriden either in container.yml during role inclusion, or by specifying your variables in a file and including them in container.yml under the `var_files` role variable as paths relative to `/src` (the path on the ansible-container conductor where your project's source code is mounted) 

- `project_name`: name of your Django project folder and project app (assumes standard django folder structure)
- `django_environment`: dictionary of environment variable definitions that will be injected into virtualenv postactivate script (see defaults/main.yml for an example)
- `requirements_file`: if your django app's requirements file does not live at the root of your repo, this can be used to specify the relative filepath
- `core_source_files`: by default `requirements_file` and the top-level directory in your repo whose name matches `project_name` will be baked into the container. Additional source files that need to be built into the image can be specified here.
- `django_static_root`: specifies the directory where django will collect static files. This should match the value of `STATIC_ROOT` in your Django settings, or be loaded with `os.environ` from a postactivate environment variable specified in `django_environment`
- `django_media_root`: same function as `django_static_root` but for the `MEDIA_ROOT` Django setting
- `manage_path`: location of project's manage.py script, defaults to the top-level directory matching `project_name`
- `sync_conductor_owner`: when rsyncing source files, determines whether the conductor's owner flag be preserved on the synced files. Default: no.
- `django_rpm_deps` and `django_apt_deps`: list of package names for either apt or yum, depending on your target distribution (note that the same package might have a slightly different name in the other package repository)
- `script_templates`: provide a list of paths relative to /src (the path on ansible-container conductor where your project is mounted) for additional Jinja2 (or plain text) script files that you would like baked into your image at /usr/bin/
    - Note: the final extension of each filename will be truncated, so `scripts/gunicorn_start.j2` would be templated into the image as `/usr/bin/gunicorn_start`


### Environment Variables
#### The following environment variables must be defined by your container.yml django service in order to deploy this role.
- `DJANGO_PORT`: port number on which django app should be served
- `DJANGO_VENV`: absolute path to the location where the django app's Python virtualenv will live (default: /venv)
- `DJANGO_USER`: name of the user who will own all application files and run the application process (default: django)

**Reasonable defaults are provided as lower-case Ansible role variables for all these values, which can be injected into your container.yml `environment` tag with quotes and YAML curly braces (e.g. DJANGO_VENV: '{{ django_venv }}')**

### Injecting Vault secrets
Currently ansible-container doesn't support Vault encrypted files and variables directly in container.yml, but you can embed secrets into your images using ansible-playbook running from the conductor.

In this role, the django_environment variable is a dictionary of environment variables that will be placed in a postactivate script which must be run before every django manage.py call

**IMPORTANT: this means any secrets which are persisted in the target image will be visible in the image itself (unless flattened during deployment), as well as by inspection on a running instance of your image.**

This is the best solution currently available for programmatically embedding secrets using ansible-container; as long as you aren't publishing your built images to a public container registry this shouldn't be much of a concern.

## License

BSD

## Author Information

Adapted from the [official ansible-container Django example project](https://github.com/ansible/django-gulp-nginx)

Written by Marcus Levine for CKM Advisors
