class Vcompress < Formula
  include Language::Python::Virtualenv

  desc "Smart hardware-accelerated video compression engine with VMAF quality gates"
  homepage "https://github.com/sunhiro/vcompress"
  url "https://github.com/sunhiro/vcompress/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "83b6038836fff34a29ca315da6bd42d33627edbfca93e6d4959db8a983034b92"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "exiftool"
  depends_on "ab-av1"
  depends_on "python@3.11"

  resource "et_xmlfile" do
    url "https://files.pythonhosted.org/packages/45/b9/7a6dd66c430e38600d832c74d314051a66cc10d0fa81309e05e5517e4f85/et_xmlfile-2.0.0.tar.gz"
    sha256 "dab1aa40cf0e9d029c7d195ee5c9b9ef36881c6db70e447b59e359ab0e0aa8cf"
  end

  resource "openpyxl" do
    url "https://files.pythonhosted.org/packages/e0/75/a6ae7e189c456ae995a97576ce1244bb0c441b4e0bf9dbe67bcf7e1933ba/openpyxl-3.1.5.tar.gz"
    sha256 "cfba99b01b69c9b4e28ab9a08c0efd5248234dbb9b7849e7b2f0a14ebaa694fb"
  end

  def install
    virtualenv_create(libexec, "python3.11")
    resources.each do |r|
      r.stage do
        system libexec/"bin/python3", "-m", "pip", "install", "--no-deps", "."
      end
    end

    libexec.install Dir["src/*"]

    # Wrap as standard terminal command
    #
    # 🔴 必须用 **venv 里的解释器**去跑脚本，两件事都得说清楚：
    #   1) 老版 `write_env_script(libexec/"vcompress_abav1.py", PYTHONPATH: libexec)`
    #      生成的是 `exec "<脚本>" "$@"`，脚本的 shebang 是 `#!/usr/bin/env python3`
    #      —— 落到 PATH 上那个**没装 openpyxl 的** Homebrew python 上。而
    #      `vcompress_abav1` 在 import 期就 `from export_report import ...`，
    #      export_report 顶层 `import openpyxl`（export_report.py:13），
    #      于是 `vcompress --help` 直接 ModuleNotFoundError —— 装完就废。
    #   2) 直接 exec .py 还要求源文件带可执行位，tarball 里不保证有。
    #      显式走 `libexec/bin/python3 <脚本>` 两条都绕开。
    # 依赖版本在 pyproject.toml(dependencies) 声明，由上面的 resources 循环装好。
    (bin/"vcompress").write_env_script(
      libexec/"bin/python3",
      libexec/"vcompress_abav1.py",
      PYTHONPATH: libexec
    )
  end

  test do
    # 这个断言能抓住上面那个 openpyxl 坑：--help 也要先 import 成功才算过
    system "#{bin}/vcompress", "--help"
  end
end
