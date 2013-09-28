
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include <QDir>
#include <QTextCodec>
#include "sailfishapplication.h"
#include "src/filtermodel.h"
#include "src/getpocketmanager.h"
#include "src/pocketentriesmodel.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QTextCodec::setCodecForLocale (QTextCodec::codecForName ("UTF-8"));
    QScopedPointer<QGuiApplication> app (Sailfish::createApplication (argc, argv));
    QScopedPointer<QQuickView> view (Sailfish::createView ());

    app->setOrganizationName ("Dellirium");
    app->setApplicationName ("LinksBag");

    auto pocketManager = new LinksBag::GetPocketManager;
    auto proxyModel = new LinksBag::FilterModel;
	auto pocketModel = new LinksBag::PocketEntriesModel;
    proxyModel->setSourceModel (pocketModel);

	QObject::connect (pocketManager,
			SIGNAL (gotEntries (QList<PocketEntry>)),
			pocketModel,
			SLOT (handleGotEntries (QList<PocketEntry>)));
    QObject::connect (pocketManager,
            SIGNAL (favoriteStateChanged (qint64)),
            pocketModel,
            SLOT (handleFavoriteStateChanged (qint64)));
    QObject::connect (pocketManager,
            SIGNAL (readStateChanged (qint64)),
            pocketModel,
            SLOT (handleReadStateChanged (qint64)));

	view->rootContext ()->setContextProperty ("pocketManager",
			pocketManager);
	view->rootContext ()->setContextProperty ("pocketModel",
            proxyModel);

    view->setSource (QUrl::fromLocalFile(Sailfish::deploymentPath () + "main.qml"));

	Sailfish::showView (view.data ());

    pocketModel->RestoreItems ();

	return app->exec ();
}


