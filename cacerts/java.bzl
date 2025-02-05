# Copyright 2017 Google Inc. All rights reserved.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def _impl(ctx):
    ctx.actions.run_shell(
        outputs = [ctx.outputs.out],
        inputs = [ctx.file.cacerts_tar],
        tools = [ctx.file._jksutil],
        arguments = [ctx.file.cacerts_tar.path, ctx.outputs.out.path],
        command = """\
mkdir -p etc/ssl/certs/java; \
tar -xOf "$1" etc/ssl/certs/ca-certificates.crt | \
  """ + ctx.file._jksutil.path + """ > etc/ssl/certs/java/cacerts; \
tar cvf "$2" etc/ssl/certs/java/cacerts
""",
    )

cacerts_java = rule(
    doc = """
Rule for converting the PEM formatted ca-certs in to JKS format. Output is a tar
file with the JKS file at etc/ssl/certs/java/cacerts.
""",
    attrs = {
        "cacerts_tar": attr.label(
            allow_single_file = [".tar"],
            mandatory = True,
        ),
        "_jksutil": attr.label(
            default = Label("//cacerts/jksutil:jksutil"),
            cfg = "host",
            executable = True,
            allow_single_file = True,
        ),
    },
    executable = False,
    outputs = {
        "out": "%{name}.tar",
    },
    implementation = _impl,
)
