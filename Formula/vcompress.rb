class Vcompress < Formula
  include Language::Python::Virtualenv

  desc "Smart hardware-accelerated video compression engine with VMAF quality gates"
  homepage "https://github.com/sunhiro/vcompress"
  url "https://github.com/sunhiro/vcompress/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "250801dcdac1c14207aaa6c3e9320a480d86a36157d822b4c65ad3a5faf61c09"
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
    (bin/"vcompress").write_env_script(
      libexec/"vcompress_abav1.py",
      PYTHONPATH: libexec
    )
  end

  test do
    system "#{bin}/vcompress", "--help"
  end
end
