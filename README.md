# Chef Solo Bootstrap Scripts

A set of shell scrips to bootstrap Chef Solo on Ubuntu and Oracle Linux.

## Purpose

Install Ruby and Chef Client (`chef-solo`) so as to cook using the excellent cookbooks and secret recipes from the community. We can all be chefs ;-)

> NOTE: When these scripts were written, the smart install [script](https://www.opscode.com/chef/install.sh) was NOT available (or I just didn't know it existed).

Technically the bootstrap scripts

* Install packages required to compile Ruby
* Download Ruby source tarball
* Compile Ruby
* Install Chef client (including `chef-solo`) as a gem

List of scripts

* bootstrap-ubuntu.sh
  
  For Ubuntu 12.04 and later, the bootstrap script uses [`rbenv`](https://github.com/sstephenson/rbenv) to manage Ruby versions.

* bootstrap-oracle-5u7.sh

  **ONLY** for Oracle Linux 5.7 DVD install with no updates from Oracle Public YUM or ULN.
  
* bootstrap-oracle-5.sh
  
  For Oracle Linux 5.x.
  
* bootstrap-oracle-6.sh

  For Oracle Linux 6.x.
  
* bootstrap-oracle-generic.sh

  Generic for Oracle Linux `{5,6}`.

## Considerations

Opscode provides a shell script to detect target OS and version, it then downloads a **self-contained** install package to install Chef client.

Since the install script does a very good job, these scripts have become kind of useless. However they are still of some value.

If you just want the Chef client, use the script or manually download the OS specific install packages to install, it is much easier to manage.

Run the following command with `root`:

```bash
curl -L https://www.opscode.com/chef/install.sh | bash
```

Or you can manually download the OS specific install package and install, up to you.

If you want an up-to-date Ruby version (for `gollum`, `GitLab` or other applications) as well as `chef-solo`, these scripts may be helpful.

> **NOTE**: Modify these scripts to meet your needs, e.g. use rbenv to manage Ruby versions for Oracle Linux, Do It Yourself;-) 
 
# Usage

Clone the repository or directly download the scripts you want, add execute bit and run;-)

> NOTE: Set proxy using environment variables before running the scripts if target machines are behind firewall.

```bash
git clone https://github.com/terrywang/chef-solo-bootstrap.git
cd chef-solo-bootstrap
chmod a+x *.sh
# Bootstrap Ubuntu 12.04
./bootstrap-ubuntu.sh
```

All bootstrap scripts for Oracle Linux requires `root`.

The bootstrap script for Ubuntu requires the executing user to have `sudo` privilege.

Enjoy cooking!

## License

Bootstrap scripts are released under the BSD license.

Copyright (c) 2013, Terry Wang
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
* Neither the name of  nor the names of its
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.