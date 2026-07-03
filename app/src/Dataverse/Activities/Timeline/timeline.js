(function () {
    'use strict';

    var root;

    function ensureRoot() {
        if (!root) {
            root = document.createElement('div');
            root.className = 'crm-timeline';
            document.body.appendChild(root);
        }
        return root;
    }

    function iconFor(type) {
        switch (type) {
            case 'Task': return '✓';          // check
            case 'Phone Call': return '☎';    // phone
            case 'Appointment': return '📅'; // calendar
            case 'Email': return '✉';         // envelope
            case 'Note': return '📝';    // memo
            default: return '•';              // bullet
        }
    }

    // Invoked from AL: CurrPage.TimelineControl.Render(json)
    window.Render = function (activitiesJson) {
        var container = ensureRoot();
        container.innerHTML = '';

        var items = [];
        try {
            items = JSON.parse(activitiesJson) || [];
        } catch (e) {
            items = [];
        }

        if (!items.length) {
            var empty = document.createElement('div');
            empty.className = 'crm-timeline-empty';
            empty.textContent = 'No activities yet.';
            container.appendChild(empty);
            return;
        }

        items.forEach(function (a) {
            var row = document.createElement('div');
            row.className = 'crm-timeline-item status-' + String(a.status || '').toLowerCase();

            var icon = document.createElement('div');
            icon.className = 'crm-timeline-icon';
            icon.textContent = iconFor(a.type);

            var body = document.createElement('div');
            body.className = 'crm-timeline-body';

            var subject = document.createElement('div');
            subject.className = 'crm-timeline-subject';
            subject.textContent = a.subject || '(no subject)';

            var meta = document.createElement('div');
            meta.className = 'crm-timeline-meta';
            meta.textContent = [a.type, a.date, a.owner].filter(Boolean).join('  •  ');

            body.appendChild(subject);
            body.appendChild(meta);

            if (a.description) {
                var desc = document.createElement('div');
                desc.className = 'crm-timeline-desc';
                desc.textContent = a.description;
                body.appendChild(desc);
            }

            row.appendChild(icon);
            row.appendChild(body);
            row.addEventListener('click', function () {
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ActivityClicked', [String(a.id)]);
            });

            container.appendChild(row);
        });
    };

    // Tell AL the control is ready so it can push the first data set.
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlReady', []);
})();
