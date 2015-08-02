package hy.rpg.components
{
	import hy.game.avatar.SAvatar;
	import hy.game.components.SAvatarComponent;
	import hy.rpg.enum.EnumLoadPriority;
	import hy.rpg.enum.EnumRenderLayer;

	public class ComponentWeapon extends SAvatarComponent
	{
		public function ComponentWeapon(type : * = null)
		{
			super(type);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			m_lazyAvatar.priority = EnumLoadPriority.WEAPON;
			m_render.layer = EnumRenderLayer.WEAPON;
			setAvatarId(m_data.weaponId);
			registerd();
		}

		override protected function onLoadAvatarComplete(avatar : SAvatar) : void
		{
			m_avatar = avatar;
		}
	}
}