defmodule BPE.Service.Store do

  def get_new_jobs do
    Path.wildcard("./tmp/jobs/*.json")
  end

  def get_template do
    %{
      subject: "Test template email",
      text: """
Hello <%= name %>,

this is a text template where this <%= parameter %> is changeable.
      """,
      html: """
<html>
<body>
  Hello <%= name %>,<br /><br />this is a text template where this <%= parameter %> is changeable.
</body>
</html>
      """
    }
  end
end
