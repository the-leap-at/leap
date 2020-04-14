import EasyMDE from 'easymde';

let easyMDESettings = {
  init() {
    Array.from(document.getElementsByClassName('easy-mde-wrapper')).forEach(
      (parent) => {
        // TODO: check if the element already has easymde attached
        let element = this.easyMDETextareaElement(parent);
        if (!!element && !this.easyMDEPresent(parent)) {
          new EasyMDE({
            element: element,
            autosave: {
              enabled: true,
              uniqueId: element.id,
              delay: 1000,
              submit_delay: 2000,
            },
            status: false,
          });
        }
      }
    );
  },

  easyMDETextareaElement(parent) {
    return Array.from(parent.children).find((el) =>
      el.classList.contains('easy-mde-textarea')
    );
  },

  easyMDEPresent(parent) {
    let element = Array.from(parent.children).find((el) =>
      el.classList.contains('CodeMirror')
    );
    return !!element;
  },
};

export default easyMDESettings;
