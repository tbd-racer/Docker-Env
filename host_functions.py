from subprocess import PIPE, Popen, call, check_output
import os, json, time, socket, pty, errno, mmap


# allows the execution of a command on the host machine
# utilizes the current user to run the command
# full_cmd: a list of strings containing the command and any arguments
# print_out: allows execute to print the output of the command
def execute(full_cmd: list, print_out: bool = False) -> int:
    # print the command string
    if print_out:
        print(" ".join(full_cmd))

    # make a pty fd
    master_fd, slave_fd = pty.openpty()

    # create the process and bind the io to the pty
    proc = Popen(
        full_cmd,
        stdin=slave_fd,
        stdout=slave_fd,
        stderr=slave_fd,
        close_fds=True,
        universal_newlines=True,
    )
    os.close(slave_fd)

    data = bytes()

    while True:
        try:
            data += os.read(master_fd, 512)
        except OSError as e:
            if e.errno != errno.EIO:
                # raise the error if the stream had a non EIO issue
                raise
            break
        else:
            if not data:
                break

        if print_out:
            try:
                print(data.decode("utf-8"), end="")
                data = bytes()
            except UnicodeDecodeError as e:
                data = data[e.start :]

    # close out the process
    os.close(master_fd)
    if proc.poll() is None:
        proc.kill()

    return proc.wait() != 0


# gets the git commit hash for the repo in the CWD
def get_git_revision_short_hash() -> str:
    return check_output(["git", "rev-parse", "--short", "HEAD"]).decode("ascii").strip()


# gets the list of local docker images
# list item includes tags
def local_docker_images() -> list:
    json_string = (
        check_output(["docker", "image", "list", "--format", "json"])
        .decode("ascii")
        .splitlines()
    )
    image_data = []
    for line in json_string:
        image_data.append(json.loads(line))
    return image_data


def docker_container_list() -> list:
    json_string = check_output(
        ["docker", "container", "list", "-a", "--format", "json"]
    ).splitlines()
    containers = []
    for line in json_string:
        containers.append(json.loads(line))
    return containers


# build a docker image with the specified tags and target arch
# Requires the cwd to be set to the directory containing the dockerfile
# tags: list of string tags for the docker image
# arch: the name of the target architecture for the image
# clean: if true, will force a no-cache build
# returns true if the build was successful
def docker_build_image(
    registry_name: str,
    image_name: str,
    tags: list,
    arch: str,
    clean: bool = False,
    file_path: str = "",
    args: list = []
) -> bool:
    # now run the docker build
    docker_cmd = [
        "docker",
        "buildx",
        "build",
        "--progress=plain",
        "--push",
    ]

    # add all of the tags in
    for tag in tags:
        docker_cmd.extend(["-t", f"{registry_name}/{image_name}:{tag}"])

    # handle the clean arg properly
    if clean:
        docker_cmd.append("--no-cache")

    # deal with a specified docker file
    if file_path != "":
        docker_cmd.extend(["-f", file_path])

    # set docker ARG values
    for arg in args:
        docker_cmd.extend(["--build-arg", arg])

    # finish the rest of the args
    docker_cmd.extend(
        [
            f"--platform={arch}",
            ".",
        ]
    )

    # build the docker image
    exit_code = execute(docker_cmd, True)
    return exit_code == 0
