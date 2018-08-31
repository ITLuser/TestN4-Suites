/*
 * Copyright (c) 2017 Navis LLC. All Rights Reserved.
 *
 */
(function (out) {
    var uuid = this.uuid,
            target = this.getTarget();

    out.push('<li', this.domAttrs_(), '>');

    out.push('<a href="', this.getHref() ? this.getHref() : 'javascript:;', '"');
    if (target) {
        out.push(' target="', target, '"');
    }
    out.push(' id="', uuid, '-a" class="', this.$s('content'), '"',
            this._disabled ? ' disabled="disabled"' : '',
            '>', this.domContent_());
    if (this.shortcutlabel != null && this.shortcutlabel != '') {
        out.push('<span class="z-shortcutlabel z-label">', this.shortcutlabel, '</span>');
    }
    else if (this.domExtraAttrs != null && this.domExtraAttrs.shortcutlabel != null) {

        out.push('<span class="z-shortcutlabel z-label">', this.domExtraAttrs.shortcutlabel, '</span>');

    }

    out.push('</a></li>'); //Merge breeze
});