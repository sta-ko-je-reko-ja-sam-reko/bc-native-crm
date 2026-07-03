(function () {
    'use strict';

    var root;

    function ensureRoot() {
        if (!root) {
            root = document.createElement('div');
            root.className = 'crm-processbar';
            document.body.appendChild(root);
        }
        return root;
    }

    // Invoked from AL: CurrPage.ProcessBar.Render(json)
    window.Render = function (processJson) {
        var container = ensureRoot();
        container.innerHTML = '';

        var process;
        try {
            process = JSON.parse(processJson) || {};
        } catch (e) {
            process = {};
        }

        var stages = process.stages || [];
        if (!stages.length) {
            var empty = document.createElement('div');
            empty.className = 'crm-processbar-empty';
            empty.textContent = 'No process.';
            container.appendChild(empty);
            return;
        }

        var bar = document.createElement('div');
        bar.className = 'crm-processbar-stages';

        stages.forEach(function (s) {
            var chevron = document.createElement('div');
            chevron.className = 'crm-processbar-stage ' + (s.state || 'todo');
            chevron.textContent = s.name;
            chevron.title = s.name;
            chevron.addEventListener('click', function () {
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('StageClicked', [String(s.no)]);
            });
            bar.appendChild(chevron);
        });

        var advance = document.createElement('button');
        advance.className = 'crm-processbar-advance';
        advance.type = 'button';
        advance.textContent = 'Advance ▶';
        advance.addEventListener('click', function () {
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('AdvanceClicked', []);
        });

        container.appendChild(bar);
        container.appendChild(advance);
    };

    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlReady', []);
})();
