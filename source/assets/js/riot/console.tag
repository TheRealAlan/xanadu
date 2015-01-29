<xanadu-console>
  <div class="console">
    <form onsubmit={ parent.console_input }>
      <textarea class="console-capture"></textarea>
    </form>
  </div>
  <script>
    console_input(ev) {
      alert(ev)
    }
  </script>
</xanadu-console>