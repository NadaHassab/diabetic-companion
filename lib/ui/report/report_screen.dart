import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diabetic_companion/services/report_service.dart';
import 'package:diabetic_companion/services/pdf_report_service.dart';
import 'package:diabetic_companion/state/app_state.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final report = ReportService.generate(
      entries: state.entries,
      targets: state.targets,
      medications: state.medications,
      intakes: state.intakes,
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor-Ready Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export as PDF',
            onPressed: () => _exportPdf(context, report),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy to clipboard',
            onPressed: () => _copyReport(context, report),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(theme, report),
          const SizedBox(height: 16),
          _sectionTitle(theme, 'Glycemic Metrics'),
          _metricRow(theme, 'Mean glucose',
              report.mean != null ? '${report.mean!.toStringAsFixed(0)} mg/dL' : '—'),
          _metricRow(theme, 'GMI',
              report.gmi != null ? '${report.gmi!.toStringAsFixed(1)}%' : '—'),
          _metricRow(theme, 'CV',
              report.cv != null ? '${report.cv!.toStringAsFixed(1)}%' : '—'),
          const SizedBox(height: 8),
          _tirBar(theme, report),
          const SizedBox(height: 16),
          _sectionTitle(theme, 'Clinical Events'),
          _metricRow(theme, 'Hypoglycemia (<70)', '${report.hypoEvents} events'),
          _metricRow(theme, 'Severe hypoglycemia (<54)', '${report.severeHypoEvents} events'),
          _metricRow(theme, 'Hyperglycemia (>250)', '${report.hyperEvents} events'),
          if (report.fastingCount > 0) ...[
            const SizedBox(height: 8),
            _sectionTitle(theme, 'Fasting Glucose'),
            _metricRow(theme, 'Fasting readings', '${report.fastingCount}'),
            if (report.fastingMean != null)
              _metricRow(theme, 'Fasting mean',
                  '${report.fastingMean!.toStringAsFixed(0)} mg/dL'),
          ],
          if (report.medicationAdherence.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionTitle(theme, 'Medication Adherence'),
            for (final line in report.medicationAdherence)
              _metricRow(theme, '', line),
          ],
          if (report.insights.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionTitle(theme, 'Trend Insights'),
            for (final insight in report.insights)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(insight.title,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(insight.body, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
          ],
          const SizedBox(height: 16),
          _sectionTitle(theme, 'Focus'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(report.focusSuggestion),
            ),
          ),
          const SizedBox(height: 16),
          _disclaimer(theme),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _header(ThemeData theme, ReportData report) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report Period',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '${_fmtDate(report.periodStart)} – ${_fmtDate(report.periodEnd)}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${report.count} readings · ${report.daysLogged}/${report.totalDays} days · ${report.stratumLabel}',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );

  Widget _sectionTitle(ThemeData theme, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      );

  Widget _metricRow(ThemeData theme, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (label.isNotEmpty)
              Text(label, style: theme.textTheme.bodyMedium),
            Text(value,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _tirBar(ThemeData theme, ReportData report) {
    final colors = [
      theme.colorScheme.error,
      theme.colorScheme.primary,
      theme.colorScheme.errorContainer,
    ];
    final values = [report.tbrPercent, report.tirPercent, report.tarPercent];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          child: Row(
            children: List.generate(3, (i) {
              final w = values[i].clamp(0, 100) / 100;
              return Expanded(
                flex: (w * 100).toInt().clamp(1, 100),
                child: Container(color: colors[i]),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TBR ${report.tbrPercent.toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error, fontWeight: FontWeight.w600)),
            Text('TIR ${report.tirPercent.toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
            Text('TAR ${report.tarPercent.toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _disclaimer(ThemeData theme) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'This report is informational and generated from your logged data. '
          'It is not a medical diagnosis. Share with your care team for clinical decisions.',
          style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant),
        ),
      );

  void _copyReport(BuildContext context, ReportData report) {
    final text = ReportService.toText(report);
    // Clipboard not available in web, show snackbar with text
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Report text ready — copy it from the text below'),
        action: SnackBarAction(
          label: 'Show',
          onPressed: () => _showReportText(context, text),
        ),
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, ReportData report) async {
    final state = context.read<AppState>();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating PDF...')),
    );
    try {
      await PdfReportService.generateAndShare(
        report: report,
        entries: state.entries,
        targets: state.targets,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF generation failed: $e')),
        );
      }
    }
  }

  void _showReportText(BuildContext context, String text) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, ctrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Report Text',
                      style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(text, style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
