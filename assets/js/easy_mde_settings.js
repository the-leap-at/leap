import EasyMDE from 'easymde';

let easyMDESettings = {
  init() {
    Array.from(document.getElementsByClassName('easy-mde-field')).forEach(
      (element) => {
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
    );
  },
};

export default easyMDESettings;
