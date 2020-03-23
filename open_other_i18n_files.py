import os
import sublime
import sublime_plugin


class OpenOtherI18nFilesCommand(sublime_plugin.TextCommand):
  LOCALES = ['en-US', 'fr-FR', 'de-DE', 'es-ES', 'pt-BR', 'zh-CN']
  LOCALES_FOLDER = '/config/locales/'

  def run(self, edit):
    # /home/alex/Code/talentoday/config/locales/en-US/users/opmi_results.yml
    full_path = self.view.file_name()

    if not self.LOCALES_FOLDER in full_path:
      return

    # en-US/users/opmi_results.yml
    rel_file_path = full_path.split(self.LOCALES_FOLDER)[1]
    # en-US
    orig_locale = rel_file_path.split('/')[0]
    # users/opmi_results.yml
    after_locale_path = rel_file_path.split('{}/'.format(orig_locale))[1]
    # opmi_results.yml
    file_name = after_locale_path.split('/')[-1]

    for locale in [locale for locale in self.LOCALES if locale != orig_locale]:
      file_to_open = full_path.replace(rel_file_path, '{}/{}'.format(locale, after_locale_path))

      if not os.path.isfile(file_to_open):
        new_dir = file_to_open.split(file_name)[0]
        if not os.path.exists(new_dir):
          os.mkdir(new_dir)

        with open(file_to_open, 'w') as file:
          file.write('{}:\n'.format(locale))

      self.view.window().open_file(file_to_open)
