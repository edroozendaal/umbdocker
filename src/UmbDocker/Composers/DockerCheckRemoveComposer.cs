using Umbraco.Cms.Core.Composing;
using Umbraco.Cms.Infrastructure.Runtime.RuntimeModeValidators;

namespace UmbDocker.Composers;

public class DockerCheckRemoveComposer : IComposer
{
  public void Compose(IUmbracoBuilder builder)
  => builder.RuntimeModeValidators().Remove<UseHttpsValidator>();
}